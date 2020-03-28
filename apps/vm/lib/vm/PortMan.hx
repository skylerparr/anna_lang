package vm;
import vm.Port;
import vm.SimplePort;
@:rtti
class PortMan {

  public static function create(haxeClass: String):Port {
    var pid: Pid = Process.self();
    return new SimplePort(haxeClass, pid);
  }

  public static function close(port: Port):Atom {
    port.dispose();
    return Atom.create('ok');
  }

  public static function send(port:Port, payload: Dynamic): Atom {
    port.receive(payload);
    return Atom.create('ok');
  }

}
