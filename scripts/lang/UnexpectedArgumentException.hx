package lang;

import lang.StandardException;
@:build(macros.ScriptMacros.script())
class UnexpectedArgumentException extends StandardException {
  public function new(msg: String) {
    super(msg);
  }
}