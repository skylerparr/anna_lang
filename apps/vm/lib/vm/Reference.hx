package vm;
import core.BaseObject;
import lang.CustomType;
class Reference implements BaseObject implements CustomType {
  private static var nextId: Int;

  private var refId: Int;

  public static function create():Reference {
    return new Reference();
  }

  public function new() {
    refId = nextId++;
  }

  public function init():Void {
  }

  public function dispose():Void {

  }

  public function toAnnaString():String {
    return '#Ref<${refId}>';
  }
}
