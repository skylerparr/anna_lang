using lang.AtomSupport;
class Atom {
  public var value: String;

  public inline function new(value: String) {
    this.value = value;
  }

  public function toString(): String {
    return '"${value}".atom()';
  }
}