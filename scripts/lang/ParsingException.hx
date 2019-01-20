package lang;

@:build(macros.ScriptMacros.script())
class ParsingException extends StandardException {
  public function new() {
    super();
  }
}