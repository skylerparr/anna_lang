import lang.CustomTypes.CustomType;
class Atom implements CustomType {
  public var value(default, never): String;

  public inline function new(value: String) {
    Reflect.setField(this, 'value', value);
  }

  public function toString(): String {
    return 'AtomSupport.atom("${value}")';
  }

  public static function to_string(atom: Atom): String {
    return atom.value;
  }
}