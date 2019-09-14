package vm;

class SimpleFunction implements Function {
  public var args: Array<Dynamic>;
  public var fn: Dynamic;

  public function new() {
  }

  public function invoke(): Array<Operation> {
    return Reflect.callMethod(null, fn, args);
  }
}