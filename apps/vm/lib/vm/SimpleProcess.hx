package vm;
using lang.AtomSupport;

class SimpleProcess implements Pid {
  public var server_id(default, null): Int;
  public var instance_id(default, null): Int;
  public var group_id(default, null): Int;
  public var processStack(default, null): DefaultProcessStack;
  public var state(default, null): ProcessState;
  public var mailbox(default, null): Array<Dynamic>;
  public var parent(default, null): Pid;
  public var ancestors(default, null): Array<Pid>;

  public inline function new() {
    this.server_id = 1;
    this.instance_id = 1;
    this.group_id = 1;
    this.state = ProcessState.RUNNING;
    this.mailbox = [];
  }

  public function start(op: Operation): Void {
    var processStack: DefaultProcessStack = new DefaultProcessStack(this);
    processStack.add(new DefaultAnnaCallStack([op], new Map<String, Dynamic>()));
    this.processStack = processStack;
  }

  public function toAnnaString(): String {
    return '#PID<${server_id}.${group_id}.${instance_id}>';
  }

  public function setParent(pid: Pid): Bool {
    parent = pid;
    return false;
  }

  public function putInMailbox(value: Dynamic): Void {
    this.mailbox.push(value);
  }

  public function setState(state: ProcessState): Void {
    this.state = state;
  }
}