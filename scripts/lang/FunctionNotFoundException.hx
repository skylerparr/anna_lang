package lang;
@:build(macros.ScriptMacros.script())
class FunctionNotFoundException extends StandardException {
  public function new(message: String) {
    super(message);
  }
}
