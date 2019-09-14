package vm;
import lang.CustomType;
interface Pid extends CustomType {
  public var server_id(default, null): Int;
  public var instance_id(default, null): Int;
  public var group_id(default, null): Int;
  public var processStack(default, null): ProcessStack;
  public var state(default, null): ProcessState;
  public var mailbox(default, null): Array<Dynamic>;
  public var parent(default, null): Pid;
  public var ancestors(default, null): Array<Pid>;

  function start(op: Operation): Void;
  function setState(state: ProcessState): Void;
  function setParent(pid: Pid): Bool;
  function putInMailbox(value: Dynamic): Void;
}
