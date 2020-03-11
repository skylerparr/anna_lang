package ;
import cpp.vm.Thread;
import vm.Port;
import vm.SynchronizedInstance;
class CPPCLIInput implements SynchronizedInstance {
  public var port:Port;
  public var thread: Thread;

  public function new() {
  }

  public function init():Void {
    thread = Thread.create(onThreadCreated);
  }

  public function dispose():Void {
    port = null;
    thread.sendMessage("exit");
    thread = null;
  }

  public function onThreadCreated():Void {
    while(true) {
      var msg = Thread.readMessage(false);
      if(msg == "exit") {
        break;
      }
      var char: Int = Sys.getChar(false);
      port.sendMessage(Tuple.create([Atom.create('ok'), char]));
    }
  }

  public function receive(payload:Dynamic):Atom {
    trace("This port doesn't handle received messages");
    return Atom.create('ok');
  }
}
