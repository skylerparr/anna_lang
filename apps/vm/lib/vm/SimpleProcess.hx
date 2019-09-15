package vm;
using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class SimpleProcess implements Pid {
  @field public static var _instanceId: Int = 0;
  @field public static var _groupId: Int = 0;
  @field public static var _nodeId: Int = 0;

  private var serverId: Int;
  private var instanceId: Int;
  private var groupId: Int;

  public var processStack(default, null): DefaultProcessStack;
  public var state(default, null): ProcessState;
  public var mailbox(default, null): Array<Dynamic>;
  public var parent(default, null): Pid;
  public var ancestors(default, null): Array<Pid>;

  public inline function new() {
    this.serverId = _nodeId;
    this.groupId = _groupId;
    this.instanceId = _instanceId++;
    this.state = ProcessState.RUNNING;
    this.mailbox = [];
  }

  public function start(op: Operation): Void {
    var processStack: DefaultProcessStack = new DefaultProcessStack(this);
    processStack.add(new DefaultAnnaCallStack([op], new Map<String, Dynamic>()));
    this.processStack = processStack;
  }

  public function toAnnaString(): String {
    return '#PID<${serverId}.${groupId}.${instanceId}>';
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