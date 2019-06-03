package vm;

import lang.AtomSupport;
import haxe.ds.ObjectMap;
import haxe.Timer;
import cpp.Lib;
import cpp.vm.Thread;
using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class Scheduler {
  @field public static var communicationThread: Thread;
  @field public static var workerThreads: Array<Thread>;
  @field public static var asyncThreads: Array<Thread>;
  @field public static var asyncFunctions: List<Tuple>;
  @field public static var index: Int;
  @field public static var asyncIndex: Int;
  @field public static var threadProcessMap: ObjectMap<Dynamic, Process>;

  public static function start(): Atom {
    if(communicationThread == null) {
      communicationThread = Thread.create(onCommunicationThreadCreated);
      workerThreads = [];
      asyncThreads = [];
      asyncFunctions = new List<Tuple>();
      threadProcessMap = new ObjectMap<Dynamic, Process>();
      for(i in 0...32) {
        var thread = Thread.create(onThreadStarted);
        workerThreads.push(thread);
      }
      for(i in 0...1) {
        var thread = Thread.create(onAsyncThreadStarted);
        asyncThreads.push(thread);
      }
      index = 0;
      asyncIndex = 0;
      return 'ok'.atom();
    } else {
      return 'already_started'.atom();
    }
  }

  public static function stop(): Atom {
    if(communicationThread != null) {
      communicationThread.sendMessage(KernelMessage.STOP);
    }
    return 'ok'.atom();
  }

  public static function onCommunicationThreadCreated(): Void {
    while(true) {
      var message: KernelMessage = Thread.readMessage(true);
      if(message == null) {
        continue;
      }
      switch(message) {
        case KernelMessage.STOP:
          for(thread in workerThreads) {
            thread.sendMessage(null);
          }
          communicationThread = null;
          workerThreads = null;
          asyncThreads = null;
          asyncFunctions = null;
          return;
        case KernelMessage.SCHEDULE(process):
          var thread: Thread = workerThreads[index++ % workerThreads.length];
          threadProcessMap.set(thread.handle, process);
          thread.sendMessage(process);
      }
    }
  }

  public static function onAsyncThreadStarted(): Void {
    while(true) {
      var nextQueue: List<Tuple> = new List<Tuple>();
      if(communicationThread == null) {
        break;
      }
      var fun: Tuple = Thread.readMessage(false);
      if(asyncFunctions == null) {
        return;
      }
      if(fun != null) {
        asyncFunctions.push(fun);
      }

      var asyncFun: Tuple = asyncFunctions.pop();
      while(asyncFun != null) {
        switch(Tuple.array(asyncFun)) {
          case [status, fun, tupleArgs] if(status == "run"):
            var args: Tuple = tupleArgs;
            var t: Tuple = Reflect.callMethod(null, fun, args.asArray());
            nextQueue.push(t);
          case [status, fun, args] if(status == "stop"):
          case _:
        }
        asyncFun = asyncFunctions.pop();
      }
      Sys.sleep(0.166666666);
      asyncFunctions = nextQueue;
    }
  }

  public static function sleep(process: Process, milliseconds: Int): Void {
    var asyncThread: Thread = asyncThreads[asyncIndex++ % asyncThreads.length];
    var now: Float = Timer.stamp();
    asyncThread.sendMessage(Tuple.create(["run", doSleep, Tuple.create([process, now, now + (milliseconds / 1000)])]));
  }

  public static function doSleep(process: Process, startTime: Float, endTime: Float): Tuple {
    if(startTime >= endTime) {
      if(process.status == ProcessState.SLEEPING) {
        Process.running(process);
      }
      Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
      return Tuple.create(["stop", doSleep, Tuple.create([process, startTime, endTime])]);
    }
    return Tuple.create(["run", doSleep, Tuple.create([process, Timer.stamp(), endTime])]);
  }

  public static function onThreadStarted(): Void {
    while(true) {
      var process: Process = Thread.readMessage(true);
      if(process == null) {
        return;
      }
      if(process.processStack == null) {
        trace('stack is null');
        continue;
      }
      if(process.status == ProcessState.STOPPED) {
        continue;
      }

      var stack: ProcessStack = process.processStack;
      var counter: Int = 0;
      var iterations: Int = Std.int(Math.random() * 2000);
      while(process.status == ProcessState.RUNNING && counter++ < iterations) {
        stack.execute();
      }
      switch(process.status) {
        case ProcessState.RUNNING:
          Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
        case _:
      }
    }
  }

}