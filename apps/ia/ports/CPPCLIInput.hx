package;
import haxe.io.Bytes;
import haxe.io.Input;
import vm.Port;
import vm.SynchronizedInstance;
class CPPCLIInput implements SynchronizedInstance {
  public var port:Port;
  public var thread: sys.thread.Thread;

  public function new() {
  }

  public function init():Void {
    thread = sys.thread.Thread.create(onThreadCreated);
  }

  public function dispose():Void {
    port = null;
    thread.sendMessage("exit");
    thread = null;
  }

  public function onThreadCreated():Void {
    while(true) {
      var msg = sys.thread.Thread.readMessage(true);
      if(msg == "exit") {
        break;
      }
      var char: Int = Sys.getChar(false);
      port.sendMessage(Tuple.create([Atom.create('ok'), char]));
    }
  }

  public function receive(payload:Dynamic):Atom {
    thread.sendMessage(null);
    return Atom.create('ok');
  }
}
