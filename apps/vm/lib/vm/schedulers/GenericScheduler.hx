package vm.schedulers;

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
  public var sleepingProcesses: List<Dynamic>;
  public var currentPid: Pid;

  public function new() {
  }

  public function start(): Atom {
    if(notRunning()) {
      processes = new UniqueList<Pid>();
      sleepingProcesses = new List<Dynamic>();
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

  public function sleep(pid: Pid, milliseconds: Float): Pid {
    if(notRunning()) {
      return pid;
    }
    pid.setState(ProcessState.SLEEPING);
    sleepingProcesses.push({pid: pid, timeout: milliseconds, callback: null, timeStamp: Timer.stamp()});
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

  public function receive(pid: Pid, callback: (Dynamic) -> Void, timeout: Float = -1): Void {
    if(notRunning()) {
      return;
    }
    if(pid.state == ProcessState.RUNNING) {
      pid.setState(ProcessState.WAITING);
      sleepingProcesses.push({pid: pid, timeout: timeout, callback: callback, timeStamp: Timer.stamp()});
    }
  }

  public function update(): Void {
    if(notRunning()) {
      return;
    }
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

  public function apply(pid: Pid, fn: Function, scopeVariables: Map<String, Dynamic>, callback: (Dynamic) -> Void): Void {
    if(notRunning()) {
      return;
    }
    var operations: Array<Operation> = fn.invoke();
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