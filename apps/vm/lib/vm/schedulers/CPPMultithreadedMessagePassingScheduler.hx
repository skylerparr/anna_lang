package vm.schedulers;
import cpp.vm.Thread.ThreadHandle;
import cpp.vm.Thread;
import util.TimeUtil;
import lang.macros.MacroTools;
import util.UniqueList;
import core.ObjectCreator;
import vm.schedulers.GenericScheduler.PidMetaData;
import haxe.ds.ObjectMap;
import core.ObjectFactory;

using lang.AtomSupport;

class CPPMultithreadedMessagePassingScheduler implements Scheduler {
  public var numberOfThreads: Int = 8;

  @inject
  public var objectCreator: ObjectCreator;

  public var pids: UniqueList<Pid>;
  public var paused: Bool;
  public var registeredPids: Map<Atom, Pid>;

  public var threadSchedulerMap: ObjectMap<ThreadHandle, GenericScheduler>;
  public var threadMap: ObjectMap<ThreadHandle, Thread>;
  public var asyncThread: Thread;

  public var allPids(get, null): Array<Pid>;

  function get_allPids():Array<Pid> {
    return allPids;
  }

  public function new() {
  }

  public function start(): Atom {
    if(notRunning()) {
      pids = new UniqueList();
      registeredPids = new Map<Atom, Pid>();
      asyncThread = Thread.create(onAsyncThreadStarted);
      threadMap = new ObjectMap<ThreadHandle, Thread>();
      threadSchedulerMap = new ObjectMap<ThreadHandle, GenericScheduler>();
      for(i in 0...numberOfThreads) {
        var scheduler: GenericScheduler = new GenericScheduler();
        scheduler.objectCreator = objectCreator;

        var thread: Thread = Thread.create(function() {
          scheduler.start();
          startScheduler(scheduler);
        });
        threadSchedulerMap.set(thread.handle, scheduler);
        threadMap.set(thread.handle, thread);
      }
      return "ok".atom();
    }
    return "already_started".atom();
  }

  private inline function getThreadWithFewestPids(): Thread {
    var threadWithFewestPids: ThreadHandle = null;
    var schedulerWithFewestPids: Scheduler = null;
    for(threadHandle in threadSchedulerMap.keys()) {
      var scheduler: GenericScheduler = threadSchedulerMap.get(threadHandle);

      if(threadWithFewestPids == null) {
        threadWithFewestPids = threadHandle;
        schedulerWithFewestPids = scheduler;
        continue;
      }
      if(schedulerWithFewestPids.allPids.length > scheduler.allPids.length) {
        threadWithFewestPids = threadHandle;
      }
    }
    return threadMap.get(threadWithFewestPids);
  }

  private inline function getThreadForPid(pid: Pid): Thread {
    var retVal: Thread = null;
    for(threadHandle in threadSchedulerMap.keys()) {
      var scheduler: GenericScheduler = threadSchedulerMap.get(threadHandle);
      if(scheduler._allPids.exists(pid)) {
        retVal = threadMap.get(threadHandle);
        break;
      } else {
        for(sleepingPidMeta in scheduler.sleepingProcesses) {
          if(sleepingPidMeta.pid == pid) {
            retVal = threadMap.get(threadHandle);
            break;
          }
        }
      }
    }
    return retVal;
  }

  private function onAsyncThreadStarted(): Void {
    var running: Bool = true;
    while(running) {
      var message: KernelMessage = Thread.readMessage(true);
      switch(message) {
        case COMPLETE(pid):
          for(scheduler in threadSchedulerMap) {
            scheduler.complete(pid);
          }
        case SEND(pid, payload):
          var thread: Thread = getThreadForPid(pid);
          thread.sendMessage(SEND(pid, payload));
        case RECEIVE(pid, fn, timeout, callback):
          var thread: Thread = getThreadForPid(pid);
          thread.sendMessage(RECEIVE(pid, fn, timeout, callback));
        case APPLY(pid, fn, args, scopeVariables, callback):
          var thread: Thread = getThreadForPid(pid);
          thread.sendMessage(APPLY(pid, fn, args, scopeVariables, callback));
        case SPAWN(fn, respondThread):
          var thread: Thread = getThreadWithFewestPids();
          if(thread.handle == respondThread.handle) {
            var scheduler: GenericScheduler = threadSchedulerMap.get(thread.handle);
            var pid = scheduler.spawn(fn);
            respondThread.sendMessage(pid);
          } else {
            thread.sendMessage(SPAWN(fn, respondThread));
          }
        case SPAWN_LINK(pid, fn, respondThread):
          var thread: Thread = getThreadWithFewestPids();
          if(thread.handle == respondThread.handle) {
            var scheduler: GenericScheduler = threadSchedulerMap.get(thread.handle);
            var pid = scheduler.spawnLink(pid, fn);
            respondThread.sendMessage(pid);
          } else {
            thread.sendMessage(SPAWN_LINK(pid, fn, respondThread));
          }
        case SLEEP(pid, milliseconds):
          var thread: Thread = getThreadForPid(pid);
          thread.sendMessage(SLEEP(pid, milliseconds));
        case EXIT(pid, signal, respondThread):
          var thread: Thread = getThreadForPid(pid);
          thread.sendMessage(EXIT(pid, signal, respondThread));
        case MONITOR(parentPid, pid):
          var thread: Thread = getThreadForPid(pid);
          thread.sendMessage(MONITOR(parentPid, pid));
        case DEMONITOR(parentPid, pid):
          var thread: Thread = getThreadForPid(pid);
          thread.sendMessage(DEMONITOR(parentPid, pid));
        case REGISTER_PID(pid, name):
          registeredPids.set(name, pid);
        case UNREGISTER_PID(name):
          registeredPids.remove(name);
        case STOP:
          running = false;
        case PAUSE | RESUME:
      }
    }
    for(thread in threadMap) {
      thread.sendMessage(STOP);
    }
    Sys.sleep(0.3);
    threadSchedulerMap = null;
    threadMap = null;
    asyncThread = null;
    registeredPids = null;
    pids = null;
  }

  private function startScheduler(scheduler: Scheduler): Void {
    var running: Bool = true;
    while(running) {
      ThreadMessageReader.readMessages(scheduler);
      if(scheduler.hasSomethingToExecute()) {
        for(i in 0...1000) {
          ThreadMessageReader.readMessages(scheduler);
          if(scheduler.hasSomethingToExecute()) {
            scheduler.update();
          } else {
            break;
          }
        }
      } else {
        Sys.sleep(0.1);
      }
    }
  }

  public function pause(): Atom {
    return "ok".atom();
  }

  public function resume(): Atom {
    return "ok".atom();
  }

  public function stop(): Atom {
    if(notRunning()) {
      return "ok".atom();
    }
    asyncThread.sendMessage(STOP);
    return "ok".atom();
  }

  public function complete(pid: Pid): Atom {
    if(notRunning()) {
      return "not_running".atom();
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMap.get(currentThread).complete(pid);
    } else {
      asyncThread.sendMessage(COMPLETE(pid));
    }
    return "ok".atom();
  }

  public function sleep(pid: Pid, milliseconds: Int): Pid {
    if(notRunning()) {
      return pid;
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMap.get(currentThread).sleep(pid, milliseconds);
    } else {
      asyncThread.sendMessage(SLEEP(pid, milliseconds));
    }
    return pid;
  }

  public function send(pid: Pid, payload: Dynamic): Atom {
    if(notRunning()) {
      return "not_running".atom();
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      return threadSchedulerMap.get(currentThread).send(pid, payload);
    } else {
      asyncThread.sendMessage(SEND(pid, payload));
      return "ok".atom();
    }
  }

  public function receive(pid: Pid, fn: Function, timeout: Null<Int> = null, callback: (Dynamic) -> Void = null): Void {
    if(notRunning()) {
      return;
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMap.get(currentThread).receive(pid, fn, timeout, callback);
    } else {
      asyncThread.sendMessage(RECEIVE(pid, fn, timeout, callback));
    }
  }

  public function update(): Void {

  }

  public function hasSomethingToExecute(): Bool {
    return false;
  }

  public function spawn(fn: Void->Operation): Pid {
    if(notRunning()) {
      return null;
    }
    asyncThread.sendMessage(SPAWN(fn, Thread.current()));
    var pid: Pid = Thread.readMessage(true);
    return pid;
  }

  public function spawnLink(parentPid: Pid, fn: Void->Operation): Pid {
    asyncThread.sendMessage(SPAWN_LINK(parentPid, fn, Thread.current()));
    var pid: Pid = Thread.readMessage(true);
    return pid;
  }

  public function monitor(parentPid: Pid, pid: Pid): Atom {
    if(notRunning()) {
      return null;
    }
    asyncThread.sendMessage(MONITOR(parentPid, pid));
    return "ok".atom();
  }

  public function demonitor(parentPid: Pid, pid: Pid): Atom {
    if(notRunning()) {
      return null;
    }
    asyncThread.sendMessage(DEMONITOR(parentPid, pid));
    return "ok".atom();
  }

  public function flag(pid: Pid, flag: Atom, value: Atom): Atom {
    pid.setTrapExit(value);
    return "ok".atom();
  }

  public function exit(pid: Pid, signal: Atom): Atom {
    if(notRunning()) {
      return null;
    }
    asyncThread.sendMessage(EXIT(pid, signal, Thread.current()));
    return Thread.readMessage(true);
  }

  public function apply(pid: Pid, fn: Function, args: Array<Dynamic>, scopeVariables: Map<String, Dynamic>, callback: (Dynamic) -> Void): Void {
    if(notRunning()) {
      return;
    }
    var scheduler: GenericScheduler = threadSchedulerMap.get(Thread.current().handle);
    scheduler.apply(pid, fn, args, scopeVariables, callback);
  }

  public function self(): Pid {
    var scheduler: Scheduler = threadSchedulerMap.get(Thread.current().handle);
    return scheduler.self();
  }

  public function registerPid(pid: Pid, name: Atom): Atom {
    asyncThread.sendMessage(REGISTER_PID(pid, name));
    return 'ok'.atom();
  }

  public function unregisterPid(name: Atom): Atom {
    asyncThread.sendMessage(UNREGISTER_PID(name));
    return 'ok'.atom();
  }

  public function getPidByName(name: Atom): Pid {
    return registeredPids.get(name);
  }

  private inline function notRunning(): Bool {
    return pids == null;
  }
}

enum KernelMessage {
  STOP;
  PAUSE;
  RESUME;
  REGISTER_PID(pid: Pid, name: Atom);
  UNREGISTER_PID(name: Atom);
  COMPLETE(pid: Pid);
  SLEEP(pid: Pid, milliseconds: Int);
  SEND(pid: Pid, payload: Dynamic);
  RECEIVE(pid: Pid, fn: Function, timeout: Null<Int>, callback: (Dynamic) -> Void);
  SPAWN(fn: Void->Operation, thread: Thread);
  SPAWN_LINK(parentPid: Pid, fn: Void->Operation, thread: Thread);
  MONITOR(parentPid: Pid, pid: Pid);
  DEMONITOR(parentPid: Pid, pid: Pid);
  EXIT(pid: Pid, signal: Atom, thread: Thread);
  APPLY(pid: Pid, fn: Function, args: Array<Dynamic>, scopeVariables: Map<String, Dynamic>, callback: (Dynamic) -> Void);
}