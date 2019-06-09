package vm;

class InvokeFunction implements Operation {
  public var func: Dynamic;
  public var args: Array<Tuple>;

  public inline function new(func: Dynamic, args: Array<Tuple>) {
    this.func = func;
    this.args = args;
  }

  public function execute(scopeVariables: Map<Tuple, Dynamic>, processStack: ProcessStack): Void {
    var functionArgs: Array<Dynamic> = [];

//    Reflect.callMethod(null, this.func, this.args);
  }

}