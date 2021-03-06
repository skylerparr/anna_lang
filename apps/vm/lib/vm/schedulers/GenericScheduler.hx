package vm.schedulers;

import haxe.CallStack;
import util.TimeUtil;
import lang.macros.MacroTools;
import util.UniqueList;
using lang.AtomSupport;

class GenericScheduler implements Scheduler {
  private static var _id: Int = 0;

  @:isVar
  public var id(get, null): Int;
  function get_id(): Int {
    return id;
  }

  public var pids: UniqueList<Pid>;
  public var paused: Bool;
  public var sleepingProcesses: UniqueList<PidMetaData>;
  public var pidMetaMap: Map<Pid, PidMetaData>;
  public var currentPid: Pid;
  public var registeredPidsMap: Map<Atom, Pid>;

  public var _allPids: UniqueList<Pid>;

  public var allPids(get, null): Array<Pid>;

  function get_allPids():Array<Pid> {
    return _allPids.asArray();
  }

  public function new() {
    id = _id++;
  }

  public function start(): Atom {
    if(notRunning()) {
      pids = new UniqueList<Pid>();
      _allPids = new UniqueList<Pid>();
      sleepingProcesses = new UniqueList<PidMetaData>();
      pidMetaMap = new Map<Pid, PidMetaData>();
      registeredPidsMap = new Map<Atom, Pid>();
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
    if(pids == null) {
      return "ok".atom();
    }
    #if !cppia
    for(pid in _allPids) {
      pid.dispose();
    }
    paused = false;
    for(pidMeta in pidMetaMap) {
      pidMeta.pid.dispose();
      pidMetaMap = null;
    }
    if(currentPid != null) {
      currentPid.dispose();
      currentPid = null;
    }
    registeredPidsMap = null;
    #end
    pids = null;
    _allPids = null;
    return "ok".atom();
  }

  public function complete(pid: Pid): Atom {
    if(notRunning()) {
      return "not_running".atom();
    }
    pid.setState(ProcessState.COMPLETE);
    #if !cppia
    pid.dispose();
    #end
    pids.remove(pid);
    _allPids.remove(pid);
    pidMetaMap.remove(pid);
    return "ok".atom();
  }

  public function sleep(pid: Pid, milliseconds: Int): Pid {
    if(notRunning()) {
      return pid;
    }
    pid.setState(ProcessState.SLEEPING);
    sleepingProcesses.push(new PidMetaData(pid, null, milliseconds, null, TimeUtil.nowInMillis()));
    pids.remove(pid);
    return pid;
  }

  public function send(pid: Pid, payload: Dynamic): Atom {
    if(notRunning()) {
      return "not_running".atom();
    }
    if(pid.state == ProcessState.RUNNING || pid.state == ProcessState.WAITING || pid.state == ProcessState.SLEEPING) {
      Logger.log(Anna.toAnnaString(pid) + ":" + Anna.toAnnaString(payload), 'send');
      pid.putInMailbox(payload);
      pids.add(pid);
      _allPids.push(pid);
    } else {
      NativeKernel.crash(Process.self());
    }
    return "ok".atom();
  }

  public function receive(pid: Pid, fn: Function, timeout: Null<Int> = null, callback: (Dynamic) -> Void = null): Void {
    if(notRunning()) {
      return;
    }
    if(pid.state == ProcessState.RUNNING) {
      pid.setState(ProcessState.WAITING);
    }
    var pidMeta: PidMetaData = new PidMetaData(pid, fn, 0, callback, TimeUtil.nowInMillis());
    pidMetaMap.set(pid, pidMeta);
    pids.add(pid);
    _allPids.push(pid);
    if(timeout != null) {
      pidMeta.timeout = timeout;
      sleepingProcesses.push(pidMeta);
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
      pids.push(sleepSpec.pid);
    }
    }

  private inline function passMessages(pid: Pid): Void {
    if(pid.state != ProcessState.WAITING) {
      return;
    }
    var pidMeta: PidMetaData = pidMetaMap.get(pid);
    if(pidMeta != null && pid.mailbox.length > 0) {
      var mailbox: Array<Dynamic> = pid.mailbox;
      var data = mailbox[pidMeta.mailboxIndex++ % mailbox.length];
      if(data != null) {
        Logger.log(data, 'data');
        Logger.log(mailbox.length, "mailbox size");
        var scopeVars: Map<String, Dynamic> = pid.processStack.getVariablesInScope();
        scopeVars.set(pidMeta.fn.args[0], data);
        scopeVars.set("$$$", data);

        pid.setState(ProcessState.RUNNING);

        apply(pid, pidMeta.fn, [data], scopeVars, function(result: Dynamic): Void {
          if(result != null) {
            mailbox.remove(data);
            pidMeta.mailboxIndex = 0;
            if(pidMeta.callback != null) {
              pidMeta.callback(result);
            }
          }
        });
        pids.add(pid);
        _allPids.push(pid);
      }
    }
  }

  public function update(): Void {
    if(notRunning()) {
      return;
    }
    scheduleSleeping();
    currentPid = pids.pop();
    if(currentPid == null) {
      return;
    }
    if(currentPid.state == ProcessState.WAITING) {
      passMessages(currentPid);
    }
    if(currentPid.state == ProcessState.RUNNING) {
      currentPid.processStack.execute();
    }
    if(currentPid.state == ProcessState.RUNNING) {
      _allPids.push(currentPid);
      pids.add(currentPid);
    }
  }

  public function hasSomethingToExecute(): Bool {
    scheduleSleeping();
    if(pids.length() > 0) {
      return true;
    }
    return false;
  }

  public function spawn(fn: Void->Operation): Pid {
    if(notRunning()) {
      return null;
    }
    var pid: Pid = new SimpleProcess();
    pid.start(fn());
    pids.add(pid);
    _allPids.push(pid);
    return pid;
  }

  public function spawnLink(parentPid: Pid, fn: Void->Operation): Pid {
    var pid = spawn(fn);
    if(pid == null) {
      return null;
    }
    pid.setParent(parentPid);
    parentPid.addChild(pid);
    return pid;
  }

  public function monitor(parentPid: Pid, pid: Pid): Atom {
    if(notRunning()) {
      return null;
    }
    pid.addMonitor(parentPid);
    return "ok".atom();
  }

  public function demonitor(parentPid: Pid, pid: Pid): Atom {
    if(notRunning()) {
      return null;
    }
    pid.removeMonitor(parentPid);
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
    if(pid.trapExit == 'true'.atom()) {
      return 'trapped'.atom();
    }
    pids.remove(pid);
    pidMetaMap.remove(pid);
    for(pidName in registeredPidsMap.keys()) {
      var regPid: Pid = registeredPidsMap.get(pidName);
      if(regPid == pid) {
        unregisterPid(pidName);
        break;
      }
    }
    if(signal == 'kill'.atom()) {
      pid.setState(ProcessState.KILLED);
    } else if(signal == 'crash'.atom()) {
      pid.setState(ProcessState.CRASHED);
    } else {
      pid.setState(ProcessState.COMPLETE);
    }
    return "killed".atom();
  }

  public function apply(pid: Pid, fn: Function, args: Array<Dynamic>, scopeVariables: Map<String, Dynamic>, callback: (Dynamic) -> Void): Void {
    if(notRunning()) {
      return;
    }
    if(pid.state != ProcessState.RUNNING) {
      trace("pid is not running");
      return;
    }
    var fnScope: Map<String, Dynamic> = fn.scope;
    for(scopeKey in fnScope.keys()) {
      if(scopeKey == "$$$") {
        continue;
      }
      scopeVariables.set(scopeKey, fnScope.get(scopeKey));
    }
    args.push(scopeVariables);
    var operations: Array<Operation> = fn.invoke(args);
    if(operations == null) {
      args.pop(); // remove the scope 
      IO.inspect('RuntimeException: No matching function for ${Anna.toAnnaString(fn)} args: ${Anna.toAnnaString(args)}, scope: ${Anna.toAnnaString(scopeVariables)}');
      NativeKernel.crash(Process.self());
      return;
    }
    if(callback != null) {
      callback(scopeVariables.get("$$$"));
    }
    var annaCallStack: AnnaCallStack = new DefaultAnnaCallStack(operations, scopeVariables);
    pid.processStack.add(annaCallStack);
  }

  public function self(): Pid {
    return currentPid;
  }

  public function registerPid(pid: Pid, name: Atom): Atom {
    registeredPidsMap.set(name, pid);
    return 'ok'.atom();
  }

  public function unregisterPid(name: Atom): Atom {
    registeredPidsMap.remove(name);
    return 'ok'.atom();
  }

  public function getPidByName(name: Atom): Pid {
    return registeredPidsMap.get(name);
  }

  public function registeredPids(): LList {
    var retVal: Array<Any> = [];
    for(name in registeredPidsMap.keys()) {
      var t: Tuple = Tuple.create([name, getPidByName(name)]);
      retVal.push(t);
    }
    return LList.create(retVal);
  }

  private inline function notRunning(): Bool {
    return pids == null;
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
