package lang;

import lang.StandardException;
class UnexpectedArgumentException extends StandardException {
  public function new(msg: String) {
    super(msg);
  }
}