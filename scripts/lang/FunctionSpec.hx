package lang;

import Atom;
@:build(macros.ScriptMacros.script())
class FunctionSpec {
  public var name: Atom;
  public var internalName: String;
  public var signature: Array<Array<Atom>>;
  public var returnType: Atom;
  public var body: Array<Dynamic>;

  public var signatureString(get, never): String;

  function get_signatureString(): String {
    var retVal: Array<String> = [];
    for(sign in signature) {
      retVal.push(sign[0].value);
    }
    return retVal.join(', ');
  }

  public inline function new(name: Atom, internalName: String, signature: Array<Array<Atom>>, returnType: Atom, body: Array<Dynamic>) {
    this.name = name;
    this.internalName = internalName;
    this.signature = signature;
    this.returnType = returnType;
    this.body = body;
  }

}