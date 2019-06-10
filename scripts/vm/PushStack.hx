package vm;

import vm.Operation;
class PushStack implements Operation {

  public var module: Atom;
  public var func: Atom;
  public var args: Array<Tuple>;

  public function new(module: Atom, func: Dynamic, args: Array<Tuple>) {
    this.module = module;
    this.func = func;
    this.args = args;
  }

  public function execute(scopeVariables: Map<Tuple, Dynamic>, processStack: ProcessStack): Void {
    var fn: Dynamic = Classes.getFunction(module, func);
    if(fn == null) {
      //TODO: handle missing function error
      Logger.inspect('throw a crazy error and kill the process!');
      return;
    }
    var operation: Array<Operation> = Reflect.callMethod(null, fn, InvokeFunction.getHaxeArgs(this.args));

    var nextScopeVariables: Map<Tuple, Dynamic> = new Map<Tuple, Dynamic>();
    for(arg in args) {
      nextScopeVariables.set(arg, scopeVariables.get(arg));
    }
    var annaCallStack: AnnaCallStack = new AnnaCallStack(operation, nextScopeVariables);
    processStack.add(annaCallStack);
  }
}