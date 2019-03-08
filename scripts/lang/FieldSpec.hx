package lang;

import lang.CustomTypes.CustomType;
using lang.AtomSupport;
class FieldSpec implements CustomType {
  public var name(default, never): Atom;
  public var type(default, never): Atom;
  public var default_value(default, never): String;

  public static var nil: FieldSpec = new FieldSpec('nil'.atom(), 'nil'.atom(), '');

  public inline function new(name: Atom, type: Atom, default_value: String) {
    Reflect.setField(this, 'name', name);
    Reflect.setField(this, 'type', type);
    Reflect.setField(this, 'default_value', default_value);
  }

  public function toString(): String {
    return Anna.inspect({name: name, type: type, default_value: default_value});
  }
}