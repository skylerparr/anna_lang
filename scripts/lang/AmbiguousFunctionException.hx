package lang;

@:build(macros.ScriptMacros.script())
class AmbiguousFunctionException extends StandardException {
  public function new(msg: String) {
    super(msg);
  }
}