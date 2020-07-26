package ;
import haxe.io.Bytes;
import haxe.io.Input;
import vm.Port;
import vm.SynchronizedInstance;
class CPPCLIInput implements SynchronizedInstance {
  public var port:Port;

  public function new() {
  }

  public function init():Void {
  }

  public function dispose():Void {
  }

  public function receive(payload:Dynamic):Atom {
    return Atom.create('ok');
  }
}
