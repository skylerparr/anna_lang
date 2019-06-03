package vm;

class InvokeFunction implements Operation {
  public var func: Dynamic;
  public var args: Array<Dynamic>;

  public inline function new(func: Dynamic, args: Array<Dynamic>) {
    this.func = func;
    this.args = args;
  }

  public function execute(scopeVariables: Map<String,Dynamic>, processStack: ProcessStack): Void {
    Reflect.callMethod(null, this.func, this.args);
  }

}