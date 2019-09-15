package vm.schedulers;

import util.TimeUtil;
import haxe.Timer;
import lang.macros.MacroTools;
import util.UniqueList;
import core.ObjectCreator;
using lang.AtomSupport;

class GenericScheduler implements Scheduler {

  @inject
  public var objectCreator: ObjectCreator;

  public var processes: UniqueList<Pid>;
  public var paused: Bool;
  public var sleepingProcesses: UniqueList<PidMetaData>;
  public var waitingProcesses: UniqueList<PidMetaData>;
  public var currentPid: Pid;

  public function new() {
  }

  public function start(): Atom {
    if(notRunning()) {
      processes = new UniqueList<Pid>();
      sleepingProcesses = new UniqueList<PidMetaData>();
      waitingProcesses = new UniqueList<PidMetaData>();
      return "ok".atom();
    }
    return "already_started".atom();
  }

  public function pause(): Atom {
    return "ok".atom();
  }

  public function resume(): Atom {
    return "ok".atom();
  }

  public function stop(): Atom {
    processes = null;
    return "ok".atom();
  }

  public function sleep(pid: Pid, milliseconds: Int): Pid {
    if(notRunning()) {
      return pid;
    }
    pid.setState(ProcessState.SLEEPING);
    sleepingProcesses.push(new PidMetaData(pid, null, milliseconds, null, TimeUtil.nowInMillis()));
    return pid;
  }

  public function send(pid: Pid, payload: Dynamic): Atom {
    if(notRunning()) {
      return "not_running".atom();
    }
    pid.putInMailbox(payload);
    if(pid.state == ProcessState.WAITING) {
      pid.setState(ProcessState.RUNNING);
    }
    return "ok".atom();
  }

  public function receive(pid: Pid, fn: Function, timeout: Null<Int> = null, callback: (Dynamic) -> Void = null): Void {
    if(notRunning()) {
      return;
    }
    if(pid.state == ProcessState.RUNNING) {
      pid.setState(ProcessState.WAITING);
      waitingProcesses.push(new PidMetaData(pid, fn, 0, callback, TimeUtil.nowInMillis()));
      if(timeout != null) {
        sleepingProcesses.push(new PidMetaData(pid, fn, timeout, callback, TimeUtil.nowInMillis()));
      }
    }
  }

  private inline function scheduleSleeping(): Void {
    var now: Int = TimeUtil.nowInMillis();
    var pidsToWake: List<PidMetaData> = new List<PidMetaData>();
    for(spec in sleepingProcesses.asArray()) {
      if(now - spec.timestamp >= spec.timeout) {
        pidsToWake.push(spec);
      }
    }
    while(pidsToWake.length > 0) {
      var sleepSpec: PidMetaData = pidsToWake.pop();
      if(sleepSpec == null) {
        break;
      }
      sleepingProcesses.remove(sleepSpec);
      sleepSpec.pid.setState(ProcessState.RUNNING);
      processes.push(sleepSpec.pid);
    }
  }

  private inline function passMessages(): Void {
    for(pidMeta in waitingProcesses.asArray()) {
      var pid: Pid = pidMeta.pid;
      waitingProcesses.remove(pidMeta);
      processes.add(pid);
      var data = pid.mailbox[pidMeta.mailboxIndex++ % pid.mailbox.length];
      if(data != null) {
        apply(pid, pidMeta.fn, [data], pid.processStack.getVariablesInScope(), function(result: Dynamic): Void {
          if(result != null) {
            pid.mailbox.remove(result);
            pid.processStack.getVariablesInScope().set("$$$", result);
            if(pidMeta.callback != null) {
              pidMeta.callback(result);
            }
          }
        });
      } else {
        waitingProcesses.add(pidMeta);
        processes.remove(pid);
      }
    }
  }

  public function update(): Void {
    if(notRunning()) {
      return;
    }
    scheduleSleeping();
    passMessages();
    currentPid = processes.pop();
    if(currentPid == null) {
      return;
    }
    if(currentPid.state == ProcessState.RUNNING) {
      currentPid.processStack.execute();
    }
    if(currentPid.state == ProcessState.RUNNING) {
      processes.add(currentPid);
    }
  }

  public function spawn(fn: Void->Operation): Pid {
    if(notRunning()) {
      return null;
    }
    var pid: Pid = objectCreator.createInstance(Pid);
    processes.add(pid);
    pid.start(fn());
    return pid;
  }

  public function spawnLink(parentPid: Pid, fn: Void->Operation): Pid {
    var pid = spawn(fn);
    if(pid == null) {
      return null;
    }
    pid.setParent(parentPid);
    return pid;
  }

  public function monitor(parentPid: Pid, pid: Pid): Atom {
    return "ok".atom();
  }

  public function demonitor(pid: Pid): Atom {
    return "ok".atom();
  }

  public function flag(pid: Pid, flag: Atom, value: Atom): Atom {
    return "ok".atom();
  }

  public function exit(pid: Pid, signal: Atom): Atom {
    pid.setState(ProcessState.KILLED);
    return "killed".atom();
  }

  public function apply(pid: Pid, fn: Function, args: Array<Dynamic>, scopeVariables: Map<String, Dynamic>, callback: (Dynamic) -> Void): Void {
    if(notRunning()) {
      return;
    }
    args.push(scopeVariables);
    var operations: Array<Operation> = fn.invoke(args);
    if(callback != null) {
      var op = new InvokeCallback(callback, "GenericScheduler".atom(), "apply".atom(), MacroTools.line());
      operations.push(op);
    }
    var annaCallStack: AnnaCallStack = new DefaultAnnaCallStack(operations, scopeVariables);
    pid.processStack.add(annaCallStack);
  }

  public function self(): Pid {
    return currentPid;
  }

  private inline function notRunning(): Bool {
    return processes == null;
  }
}

class PidMetaData {
  public var pid: Pid;
  public var timeout: Int;
  public var callback: Dynamic->Void;
  public var timestamp: Int;
  public var mailboxIndex: Int;
  public var fn: Function;

  public function new(pid: Pid, fn: Function, timeout: Int, callback: Dynamic->Void, timestamp: Int) {
    this.pid = pid;
    this.timeout = timeout;
    this.callback = callback;
    this.timestamp = timestamp;
    this.fn = fn;
  }
}