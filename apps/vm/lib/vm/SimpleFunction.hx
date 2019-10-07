package vm;

class SimpleFunction implements Function {
  public var args: Array<Dynamic>;
  public var fn: Dynamic;
  public var scope: Map<String, Dynamic>;

  public function new() {
  }

  public function invoke(callArgs: Array<Dynamic>): Array<Operation> {
    return Reflect.callMethod(null, fn, callArgs);
  }
}