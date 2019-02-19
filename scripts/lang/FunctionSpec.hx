package lang;

@:build(macros.ScriptMacros.script())
class FunctionSpec {
  public var name: Atom;
  public var signature: Array<Dynamic>;
  public var body: Array<Dynamic>;

  public inline function new(name: Atom, signature: Array<Dynamic>, body: Array<Dynamic>) {
    this.name = name;
    this.signature = signature;
    this.body = body;
  }

}