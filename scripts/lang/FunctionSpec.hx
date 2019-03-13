package lang;

import TypePrinter.CustomTypePrinter;
import lang.CustomTypes.CustomType;
import Atom;
using lang.AtomSupport;
class FunctionSpec implements CustomType {
  public var name(default, never): Atom;
  public var internal_name(default, never): String;
  public var signature(default, never): Array<Array<Atom>>;
  public var return_type(default, never): Atom;
  public var body(default, never): Array<Dynamic>;

  public static var nil: FunctionSpec = new FunctionSpec('nil'.atom(), '', [[]], 'nil'.atom(), []);

  public inline function new(name: Atom, internalName: String, signature: Array<Array<Atom>>, returnType: Atom, body: Array<Dynamic>) {
    Reflect.setField(this, 'name', name);
    Reflect.setField(this, 'internal_name', internalName);
    Reflect.setField(this, 'signature', signature);
    Reflect.setField(this, 'return_type', returnType);
    Reflect.setField(this, 'body', body);
  }

  public function toString(): String {
    return toHaxeString();
  }

  public function toAnnaString(): String {
    return CustomTypePrinter.asString(this);
  }

  public function toHaxeString(): String {
    return 'new lang.FunctionSpec(${Anna.toHaxeString(name)}, ${Anna.toHaxeString(internal_name)}, ${Anna.toHaxeString(signature)}, ${Anna.toHaxeString(return_type)}, ${Anna.toHaxeString(body)})';
  }

  public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
    return '';
  }
}