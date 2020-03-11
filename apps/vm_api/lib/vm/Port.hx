package vm;
import core.BaseObject;
import lang.CustomType;
interface Port extends BaseObject extends CustomType {
  function receive(payload:Dynamic):Void;
  function sendMessage(payload:Tuple):Void;
}
