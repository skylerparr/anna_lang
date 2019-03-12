package lang;

import TypePrinter.CustomTypePrinter;
import lang.CustomTypes.CustomType;
class TypeSpec implements CustomType {

  public var name(default, never): Atom;
  public var fields(default, never): Array<FieldSpec>;
  public var class_name(default, never): Atom;
  public var package_name(default, never): Atom;

  public inline function new(typeName: Atom, fields: Array<FieldSpec>, className: Atom, packageName: Atom) {
    Reflect.setField(this, 'name', typeName);
    Reflect.setField(this, 'fields', fields);
    Reflect.setField(this, 'class_name', className);
    Reflect.setField(this, 'package_name', packageName);
  }

  public function toString(): String {
    return Anna.inspect(this);
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