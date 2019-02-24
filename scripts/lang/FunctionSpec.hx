package lang;

import lang.CustomTypes.CustomType;
import Atom;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class FunctionSpec implements CustomType {
  public var name: Atom;
  public var internalName: String;
  public var signature: Array<Array<Atom>>;
  public var returnType: Atom;
  public var body: Array<Dynamic>;

  public inline function new(name: Atom, internalName: String, signature: Array<Array<Atom>>, returnType: Atom, body: Array<Dynamic>) {
    this.name = name;
    this.internalName = internalName;
    this.signature = signature;
    this.returnType = returnType;
    this.body = body;
  }

  public function toString(): String {
    return Anna.inspect({name: name, internalName: internalName, signature: signature, returnType: returnType, body: "[...]"});
  }
}