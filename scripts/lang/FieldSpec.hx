package lang;

import TypePrinter.CustomTypePrinter;
import lang.CustomTypes.CustomType;
using lang.AtomSupport;
class FieldSpec implements CustomType {
  public var name(default, never): Atom;
  public var type(default, never): Atom;

  public static var nil: FieldSpec = new FieldSpec('nil'.atom(), 'nil'.atom());

  public inline function new(name: Atom, type: Atom) {
    Reflect.setField(this, 'name', name);
    Reflect.setField(this, 'type', type);
  }

  public function toString(): String {
    return Anna.inspect({name: name, type: type});
  }

  public function toAnnaString(): String {
    return CustomTypePrinter.asString(this);
  }

  public function toHaxeString(): String {
    return '';
  }

  public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
    return '';
  }
}