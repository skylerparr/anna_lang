package lang;

class UnableToMatchException extends StandardException {
  public function new(message: String) {
    super(message);
  }
}