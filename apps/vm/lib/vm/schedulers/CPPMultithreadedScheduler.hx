package vm.schedulers;
import core.ObjectFactory;
import vm.Scheduler;
import cpp.vm.Mutex;
import haxe.ds.ObjectMap;
import cpp.vm.Thread;
import util.UniqueList;
import core.ObjectCreator;
import minject.Injector;
using lang.AtomSupport;

class CPPMultithreadedScheduler implements Scheduler {
  public var numberOfThreads: Int = 8;

  @inject
  public var objectCreator: ObjectCreator;

  public var pids: UniqueList<Pid>;
  public var paused: Bool;
  public var registeredPids: Map<Atom, Pid>;
  public var registeredPidsMutex: Mutex;

  public var threadSchedulerMessagesMap: ObjectMap<ThreadHandle, SchedulerMessages>;
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
      registeredPidsMutex = new Mutex();
      asyncThread = Thread.create(onAsyncThreadStarted);
      threadMap = new ObjectMap<ThreadHandle, Thread>();
      threadSchedulerMessagesMap = new ObjectMap<ThreadHandle, SchedulerMessages>();
      var messages: SchedulerMessages;
      for(i in 0...numberOfThreads) {
        var scheduler: GenericScheduler = new GenericScheduler();

        var objectFactory: ObjectFactory = new ObjectFactory();
        objectFactory.injector = new Injector();
        objectFactory.injector.mapValue(ObjectCreator, objectFactory);
        objectFactory.injector.mapClass(Pid, SimpleProcess);
        scheduler.objectCreator = objectCreator;

        messages = {scheduler: scheduler, mutex: new Mutex(),
          listUsedByScheduler: new List<MTSchedMessage>(), list: new List<MTSchedMessage>()};

        var thread: Thread = Thread.create(function() {
          scheduler.start();
          startScheduler(messages);
        });
        threadSchedulerMessagesMap.set(thread.handle, messages);
        threadMap.set(thread.handle, thread);
      }
      return "ok".atom();
    }
    return "already_started".atom();
  }

  private inline function getThreadWithFewestPids(): Thread {
    var threadWithFewestPids: ThreadHandle = null;
    var schedulerWithFewestPids: Scheduler = null;
    for(threadHandle in threadSchedulerMessagesMap.keys()) {
      var scheduler: Scheduler = threadSchedulerMessagesMap.get(threadHandle).scheduler;

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
    for(threadHandle in threadSchedulerMessagesMap.keys()) {
      var scheduler: Scheduler = threadSchedulerMessagesMap.get(threadHandle).scheduler;
      if(cast(scheduler, GenericScheduler)._allPids.exists(pid)) {
        retVal = threadMap.get(threadHandle);
        break;
      } else {
        for(sleepingPidMeta in cast(scheduler, GenericScheduler).sleepingProcesses) {
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
    //this is a bit of a placeholder.
  }

  private function startScheduler(messages: SchedulerMessages): Void {
    var running: Bool = true;
    var scheduler: Scheduler = messages.scheduler;
    while(running) {
      running = handleMessages(messages);
      if(running && scheduler.hasSomethingToExecute()) {
        for(i in 0...1000) {
          running = handleMessages(messages);
          if(running && scheduler.hasSomethingToExecute()) {
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

  private inline function handleMessages(schedulerMessages: SchedulerMessages): Bool {
    var running: Bool = true;
    var scheduler: Scheduler = schedulerMessages.scheduler;
    var messages: List<MTSchedMessage> = getAndClearMessages(schedulerMessages);
    for(message in messages) {
      var message = messages.pop();
      switch(message) {
        case SEND(pid, payload):
          scheduler.send(pid, payload);
        case RECEIVE(pid, fn, timeout, callback):
          scheduler.receive(pid, fn, timeout, callback);
        case APPLY(pid, fn, args, scopeVariables, callback):
          scheduler.apply(pid, fn, args, scopeVariables, callback);
        case COMPLETE(pid):
          scheduler.complete(pid);
        case SPAWN(fn, respondThread):
          var response = scheduler.spawn(fn);
          respondThread.sendMessage(response);
        case SPAWN_LINK(parentPid, fn, respondThread):
          var response = scheduler.spawnLink(parentPid, fn);
          respondThread.sendMessage(response);
        case SLEEP(pid, milliseconds):
          scheduler.sleep(pid, milliseconds);
        case EXIT(pid, signal, respondThread):
          var response = scheduler.exit(pid, signal);
          respondThread.sendMessage(response);
        case MONITOR(parentPid, pid):
          scheduler.monitor(parentPid, pid);
        case DEMONITOR(parentPid, pid):
          scheduler.demonitor(parentPid, pid);
        case STOP:
          scheduler.stop();
          running = false;
          break;
        case _:
      }
    }
    return running;
  }

  private inline function getAndClearMessages(messages: SchedulerMessages): List<MTSchedMessage> {
    var listUsedByScheduler = messages.listUsedByScheduler;
    if(messages.list.length != 0) {
      messages.mutex.acquire();
      var list: List<MTSchedMessage> = messages.list;
      var msg: MTSchedMessage = list.pop();
      while(msg != null) {
        listUsedByScheduler.push(msg);
        msg = list.pop();
      }
      messages.mutex.release();
    }
    return listUsedByScheduler;
  }

  public function pause(): Atom {
    return "ok".atom();
  }

  public function resume(): Atom {
    return "ok".atom();
  }

  private inline function push(messages: SchedulerMessages, msg: MTSchedMessage): Void {
    var msgs: List<MTSchedMessage> = messages.list;
    messages.mutex.acquire();
    msgs.push(msg);
    messages.mutex.release();
  }

  public function stop(): Atom {
    if(notRunning()) {
      return "ok".atom();
    }
    for(messages in threadSchedulerMessagesMap) {
      push(messages, STOP);
    }
    return "ok".atom();
  }

  public function complete(pid: Pid): Atom {
    if(notRunning()) {
      return "not_running".atom();
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMessagesMap.get(currentThread).scheduler.complete(pid);
    } else {
      var threadForPid: ThreadHandle = getThreadForPid(pid).handle;
      push(threadSchedulerMessagesMap.get(threadForPid), COMPLETE(pid));
    }
    return "ok".atom();
  }

  public function sleep(pid: Pid, milliseconds: Int): Pid {
    if(notRunning()) {
      return pid;
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMessagesMap.get(currentThread).scheduler.sleep(pid, milliseconds);
    } else {
      var threadForPid: ThreadHandle = getThreadForPid(pid).handle;
      push(threadSchedulerMessagesMap.get(threadForPid), SLEEP(pid, milliseconds));
    }
    return pid;
  }

  public function send(pid: Pid, payload: Dynamic): Atom {
    if(notRunning()) {
      return "not_running".atom();
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      var currentThread: ThreadHandle = Thread.current().handle;
      threadSchedulerMessagesMap.get(currentThread).scheduler.send(pid, payload);
    } else {
      var threadForPid: ThreadHandle = getThreadForPid(pid).handle;
      push(threadSchedulerMessagesMap.get(threadForPid), SEND(pid, payload));
    }
    return "ok".atom();
  }

  public function receive(pid: Pid, fn: Function, timeout: Null<Int> = null, callback: (Dynamic) -> Void = null): Void {
    if(notRunning()) {
      return;
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMessagesMap.get(currentThread).scheduler.receive(pid, fn, timeout, callback);
    } else {
      var threadForPid: ThreadHandle = getThreadForPid(pid).handle;
      push(threadSchedulerMessagesMap.get(threadForPid), RECEIVE(pid, fn, timeout, callback));
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
    var currentThread = getThreadWithFewestPids().handle;
    if(currentThread == Thread.current().handle) {
      return threadSchedulerMessagesMap.get(currentThread).scheduler.spawn(fn);
    } else {
      push(threadSchedulerMessagesMap.get(currentThread), SPAWN(fn, Thread.current()));
      var pid: Pid = Thread.readMessage(true);
      return pid;
    }
  }

  public function spawnLink(parentPid: Pid, fn: Void->Operation): Pid {
    var currentThread = getThreadWithFewestPids().handle;
    if(currentThread == Thread.current().handle) {
      return threadSchedulerMessagesMap.get(currentThread).scheduler.spawnLink(parentPid, fn);
    } else {
      var threadForPid: ThreadHandle = getThreadForPid(parentPid).handle;
      push(threadSchedulerMessagesMap.get(threadForPid), SPAWN_LINK(parentPid, fn, Thread.current()));
      var pid: Pid = Thread.readMessage(true);
      return pid;
    }
  }

  public function monitor(parentPid: Pid, pid: Pid): Atom {
    if(notRunning()) {
      return null;
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMessagesMap.get(currentThread).scheduler.monitor(parentPid, pid);
    } else {
      var threadForPid: ThreadHandle = getThreadForPid(parentPid).handle;
      push(threadSchedulerMessagesMap.get(parentPid), MONITOR(parentPid, pid));
    }
    return "ok".atom();
  }

  public function demonitor(parentPid: Pid, pid: Pid): Atom {
    if(notRunning()) {
      return null;
    }
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMessagesMap.get(currentThread).scheduler.demonitor(parentPid, pid);
    } else {
      var threadForPid: ThreadHandle = getThreadForPid(parentPid).handle;
      push(threadSchedulerMessagesMap.get(threadForPid), DEMONITOR(parentPid, pid));
    }
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
    var currentThread: ThreadHandle = Thread.current().handle;
    if(currentThread == getThreadForPid(pid).handle) {
      threadSchedulerMessagesMap.get(currentThread).scheduler.exit(pid, signal);
    } else {
      var threadForPid: ThreadHandle = getThreadForPid(pid).handle;
      push(threadSchedulerMessagesMap.get(currentThread), EXIT(pid, signal, Thread.current()));
    }

    return Thread.readMessage(true);
  }

  public function apply(pid: Pid, fn: Function, args: Array<Dynamic>, scopeVariables: Map<String, Dynamic>, callback: (Dynamic) -> Void): Void {
    if(notRunning()) {
      return;
    }
    var scheduler: Scheduler = threadSchedulerMessagesMap.get(Thread.current().handle).scheduler;
    scheduler.apply(pid, fn, args, scopeVariables, callback);
  }

  public function self(): Pid {
    var scheduler: Scheduler = threadSchedulerMessagesMap.get(Thread.current().handle).scheduler;
    return scheduler.self();
  }

  public function registerPid(pid: Pid, name: Atom): Atom {
    registeredPidsMutex.acquire();
    registeredPids.set(name, pid);
    registeredPidsMutex.release();
    return 'ok'.atom();
  }

  public function unregisterPid(name: Atom): Atom {
    registeredPidsMutex.acquire();
    registeredPids.remove(name);
    registeredPidsMutex.release();
    return 'ok'.atom();
  }

  public function getPidByName(name: Atom): Pid {
    registeredPidsMutex.acquire();
    var retVal: Pid = registeredPids.get(name);
    registeredPidsMutex.release();
    return retVal;
  }

  private inline function notRunning(): Bool {
    return pids == null;
  }
}

typedef SchedulerMessages = {
  scheduler: Scheduler,
  mutex: Mutex,
  list: List<MTSchedMessage>,
  listUsedByScheduler: List<MTSchedMessage>
}

enum MTSchedMessage {
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