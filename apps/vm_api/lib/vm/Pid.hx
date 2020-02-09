package vm;
import core.BaseObject;
import lang.CustomType;
interface Pid extends BaseObject extends CustomType {
  public var processStack(default, null): ProcessStack;
  public var state(default, null): ProcessState;
  public var mailbox(default, null): Array<Dynamic>;
  public var parent(default, null): Pid;
  public var children(get, null): Array<Pid>;
  public var ancestors(default, null): Array<Pid>;
  public var trapExit(default, null): Atom;

  function started(): Bool;

  function start(op: Operation): Void;
  function setState(state: ProcessState): Void;
  function setParent(pid: Pid): Bool;
  function addChild(pid: Pid): Void;
  function removeChild(pid: Pid): Void;
  function putInMailbox(value: Dynamic): Void;
  function setTrapExit(flag: Atom): Void;
  function addMonitor(pid: Pid): Void;
  function removeMonitor(pid: Pid): Void;

}
