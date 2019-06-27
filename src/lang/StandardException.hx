package lang;

class StandardException {

  public var message: String;

  public inline function new(message: String) {
    this.message = message;
  }

  public function toString(): String {
    return message;
  }
}