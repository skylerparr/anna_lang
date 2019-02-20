package lang;

import Atom;
@:build(macros.ScriptMacros.script())
class FunctionSpec {
  public var name: Atom;
  public var signature: Array<Array<Atom>>;
  public var returnType: Atom;
  public var body: Array<Dynamic>;

  public inline function new(name: Atom, signature: Array<Array<Atom>>, returnType: Atom, body: Array<Dynamic>) {
    this.name = name;
    this.signature = signature;
    this.returnType = returnType;
    this.body = body;
  }

}