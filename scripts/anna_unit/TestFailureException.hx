package anna_unit;

@:build(macros.ScriptMacros.script())
class TestFailureException {
  public var message: String;

  public function new(message: String) {
    this.message = message;
  }
}