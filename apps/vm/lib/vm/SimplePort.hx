package vm;
import vm.Port;
import lang.AbstractCustomType;
import vm.SynchronizedInstance;
import vm.Process;

class SimplePort extends AbstractCustomType implements Port {
  private static var __id: Int;

  private var pid: Pid;
  private var instance: SynchronizedInstance;

  public function new(haxeClass: String, pid: Pid) {
    __id++;
    this.pid = pid;
    var cls: Class<SynchronizedInstance> = cast Type.resolveClass(haxeClass);
    if(cls == null) {
      throw new UnsupportedPortType('${haxeClass} must implement vm.SynchronizedInstance');
    }
    instance = Type.createInstance(cls, []);
    instance.port = this;
    instance.init();
  }

  public function init(): Void {

  }

  public function dispose():Void {
    instance.dispose();
  }

  public function receive(payload:Dynamic):Void {
    instance.receive(payload);
  }

  public function sendMessage(payload:Tuple):Void {
    if(Process.isAlive(pid) == Atom.create('false')) {
      dispose();
      return;
    }
    NativeKernel.send(pid, payload);
  }

  override public function toAnnaString():String {
    return '#Port<${__id}>';
  }

}
