package vm;

import vm.Classes.Function;
import lang.AtomSupport;
import haxe.ds.ObjectMap;
import haxe.Timer;
import cpp.vm.Thread;
using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class Scheduler {
  @field public static var communicationThread: Thread;
  @field public static var workerThreads: Array<Thread>;
  @field public static var asyncThread: Thread;
  @field public static var index: Int;
  @field public static var asyncIndex: Int;
  @field public static var threadProcessMap: ObjectMap<Dynamic, Process>;

  public static function start(): Atom {
    if(communicationThread == null) {
      communicationThread = Thread.create(threadCommunicator);
      workerThreads = [];
      threadProcessMap = new ObjectMap<Dynamic, Process>();
      for(i in 0...32) {
        var thread = Thread.create(workerThread);
        workerThreads.push(thread);
      }
      asyncThread = Thread.create(asyncThreadLoop);
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

  public static function threadCommunicator(): Void {
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
          asyncThread = null;
          return;
        case KernelMessage.SCHEDULE(process):
          var thread: Thread = workerThreads[index++ % workerThreads.length];
          threadProcessMap.set(thread.handle, process);
          thread.sendMessage(process);
        case KernelMessage.RECEIVE(process, matcher):
          Process.receive(process, matcher);
        case KernelMessage.SEND(process, payload):
          Process.putInMailbox(process, payload);
      }
    }
  }

  public static function asyncThreadLoop(): Void {
    var nextQueue: List<Tuple> = null;
    var asyncFunctions: List<Tuple> = new List<Tuple>();
    while(true) {
      if(communicationThread == null) {
        break;
      }
      var fun: Tuple = Thread.readMessage(false);
      if(fun != null) {
        if(asyncFunctions == null) {
          asyncFunctions = new List<Tuple>();
        }
        asyncFunctions.push(fun);
      }
      if(asyncFunctions != null) {
        var asyncFun: Tuple = asyncFunctions.pop();
        while(asyncFun != null) {
          switch(Tuple.array(asyncFun)) {
            case [status, fun, tupleArgs] if(status == "run"):
              var args: Tuple = tupleArgs;
              var t: Tuple = Reflect.callMethod(null, fun, args.asArray());
              if(nextQueue == null) {
                nextQueue = new List<Tuple>();
              }
              nextQueue.push(t);
            case [status, fun, args] if(status == "stop"):
            case _:
          }
          asyncFun = asyncFunctions.pop();
        }
      }
      Sys.sleep(0.016);
      asyncFunctions = nextQueue;
      nextQueue = null;
    }
  }

  public static function sleep(process: Process, milliseconds: Int): Void {
    var now: Float = Timer.stamp();
    asyncThread.sendMessage(Tuple.create(["run", doSleep, Tuple.create([process, now, now + (milliseconds / 1000)])]));
  }

  public static function doSleep(process: Process, startTime: Float, endTime: Float): Tuple {
    if(startTime >= endTime) {
      if(process.state == ProcessState.SLEEPING) {
        Process.running(process);
      }
      Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
      return Tuple.create(["stop", doSleep, Tuple.create([process, startTime, endTime])]);
    }
    return Tuple.create(["run", doSleep, Tuple.create([process, Timer.stamp(), endTime])]);
  }

  public static function receive(process: Process, callback: Function): Void {
    asyncThread.sendMessage(Tuple.create(["run", doReceive, Tuple.create([process, callback, 0])]));
  }

  public static function doReceive(process: Process, callback: Function, mailboxIndex: Int): Tuple {
    var data = process.mailbox[mailboxIndex % process.mailbox.length];
    if(data != null) {
      if(process.state == ProcessState.WAITING) {
        Process.running(process);
      }
      Kernel.apply(process, callback, LList.create([Tuple.create(["const".atom(), data])]), function(result): Void {
        if(result == null) {
          asyncThread.sendMessage(Tuple.create(["run", doReceive, Tuple.create([process, callback, ++mailboxIndex])]));
        } else {
          process.mailbox.remove(data);
          Process.self().processStack.getVariablesInScope().set("$$$", result);
        }
      });
      Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
      return Tuple.create(["stop", doReceive, Tuple.create([process, callback, mailboxIndex])]);
    }
    return Tuple.create(["run", doReceive, Tuple.create([process, callback, ++mailboxIndex])]);
  }

  public static function workerThread(): Void {
    while(true) {
      var process: Process = Thread.readMessage(true);
      if(process == null) {
        return;
      }
      if(process.processStack == null) {
        trace('stack is null');
        continue;
      }
      if(process.state == ProcessState.KILLED) {
        continue;
      }

      var stack: ProcessStack = process.processStack;
      var counter: Int = 0;
      var iterations: Int = Std.int(Math.random() * 2000);
      while(process.state == ProcessState.RUNNING && counter++ < iterations) {
        stack.execute();
      }
      switch(process.state) {
        case ProcessState.RUNNING:
          Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
        case _:
      }
    }
  }

}