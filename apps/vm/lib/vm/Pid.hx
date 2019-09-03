package vm;
import lang.CustomTypes.CustomType;
interface Pid extends CustomType {
  public var server_id(default, never): Int;
  public var instance_id(default, never): Int;
  public var group_id(default, never): Int;
  public var processStack(default, never): ProcessStack;
  public var state(default, never): ProcessState;
  public var mailbox(default, never): Array<Dynamic>;
}
