package lang;
@:build(macros.ScriptMacros.script())
class FunctionClauseNotFound extends StandardException {
    public function new(msg: String) {
      super(msg);
    }
}
