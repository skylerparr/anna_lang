package vm;
import core.BaseObject;
import lang.CustomType;
class Reference implements BaseObject implements CustomType {
  private var refId: String;

  public static function create():Reference {
    return new Reference();
  }

  public function new() {
    refId = haxe.crypto.Sha256.encode('${Math.random()}');
  }

  public function init():Void {
  }

  public function dispose():Void {
    refId = null;
  }

  public function toAnnaString():String {
    return '#Ref<${refId}>';
  }
}
