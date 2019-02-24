package lang;

@:build(macros.ScriptMacros.script())
class StandardException {

  public var message: String;

  public inline function new(message: String) {
    this.message = message;
  }

  public function toString(): String {
    return message;
  }
}