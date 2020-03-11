package vm;
import core.BaseObject;
interface SynchronizedInstance extends BaseObject {
  var port: Port;
  function receive(payload: Dynamic): Atom;
}
