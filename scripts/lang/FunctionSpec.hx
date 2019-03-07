package lang;

import lang.CustomTypes.CustomType;
import Atom;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
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
    return Anna.inspect({name: name, internalName: internal_name, signature: signature, returnType: return_type, body: "[...]"});
  }
}