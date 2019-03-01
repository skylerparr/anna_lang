using lang.AtomSupport;
class Atom {
  public var value(default, never): String;

  public inline function new(value: String) {
    Reflect.setField(this, 'value', value);
  }

  public function toString(): String {
    return '"${value}".atom()';
  }

  public static function to_string(atom: Atom): String {
    return atom.value;
  }
}