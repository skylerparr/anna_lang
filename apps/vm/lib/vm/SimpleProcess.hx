package vm;
import util.UniqueList;
import lang.ParsingException;
import lang.AbstractCustomType;
using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class SimpleProcess extends AbstractCustomType implements Pid {
  @field public static var _instanceId: Int = 0;
  @field public static var _groupId: Int = 0;
  @field public static var _nodeId: Int = 0;

  private var serverId: Int;
  private var instanceId: Int;
  private var groupId: Int;
  private var monitors: List<Pid>;
  private var _children: UniqueList<Pid>;

  public var processStack(default, null): DefaultProcessStack;
  public var state(default, null): ProcessState;
  public var mailbox(default, null): Array<Dynamic>;
  public var parent(default, null): Pid;
  public var ancestors(default, null): Array<Pid>;
  public var trapExit(default, null): Atom;
  public var children(get, null):Array<Pid>;
  public var dictionary: MMap;

  function get_children():Array<Pid> {
    #if cppia
    if(this._children == null) {
      this._children = new UniqueList();
    }
    #end
    return this._children.asArray();
  }

  public inline function new() {
    this.serverId = _nodeId;
    this.groupId = _groupId;
    this.instanceId = _instanceId++;
    this.state = ProcessState.RUNNING;
    this.mailbox = [];
    this._children = new UniqueList();
    this.trapExit = Atom.create('false');
  }

  public function init(): Void {
  }

  public function dispose(): Void {
    if(mailbox == null) {
      return;
    }
    if(processStack != null) {
      processStack.dispose();
      processStack = null;
    }
    if(monitors != null) {
      for(pid in monitors) {
        var reason: String = switch(state) {
          case ProcessState.KILLED:
            'killed';
          case ProcessState.COMPLETE:
            'complete';
          case ProcessState.CRASHED:
            'crashed';
          case _:
            'UNKNOWN';
        }
        NativeKernel.send(pid, Tuple.create([Atom.create('DOWN'), this, Atom.create(reason)]));
      }
      monitors = null;
    }
    for(childPid in _children) {
      NativeKernel.exit(childPid, 'kill'.atom());
    }
    if(parent != null) {
      NativeKernel.exit(parent, 'kill'.atom());
    }
    mailbox = null;
    parent = null;
    ancestors = null;
    _children = null;
  }

  public function start(op: Operation): Void {
    dictionary = MMap.create([]);
    processStack = new DefaultProcessStack(this);
    processStack.add(new DefaultAnnaCallStack([op], new Map<String, Dynamic>()));
  }

  override public function toAnnaString(): String {
    return '#PID<${serverId}.${groupId}.${instanceId}>';
  }

  public function setParent(pid: Pid): Bool {
    parent = pid;
    return true;
  }

  public function putInMailbox(value: Dynamic): Void {
    this.mailbox.push(value);
  }

  public function setState(state: ProcessState): Void {
    if(this.state == ProcessState.COMPLETE || this.state == ProcessState.CRASHED || this.state == ProcessState.KILLED) {
      return;
    }
    this.state = state;
    if(state == ProcessState.COMPLETE || state == ProcessState.CRASHED || state == ProcessState.KILLED) {
      dispose();
    }
  }

  public function setTrapExit(flag: Atom): Void {
    trapExit = flag;
  }

  public function addMonitor(pid: Pid): Void {
    if(this.state == ProcessState.COMPLETE || this.state == ProcessState.CRASHED || this.state == ProcessState.KILLED) {
      return;
    }
    if(monitors == null) {
      monitors = new List<Pid>();
    }
    #if !cppia
    monitors.remove(pid);
    #end
    monitors.add(pid);
  }

  public function removeMonitor(pid: Pid): Void {
    if(monitors == null) {
     return;
    }
    monitors.remove(pid);
    if(monitors.length == 0) {
      monitors = null;
    }
  }

  public function addChild(pid:Pid):Void {
    this._children.add(pid);
  }

  public function removeChild(pid:Pid):Void {
    this._children.remove(pid);
  }
}