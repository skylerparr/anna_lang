package vm;

import vm.Classes.Function;
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
    var fn: Function = Classes.getFunction(module, func);
    if(fn == null) {
      //TODO: handle missing function error
      Logger.inspect('throw a crazy error and kill the process!');
      return;
    }
    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(i in 0...fn.args.length) {
      var argName: String = fn.args[i];
      var argValue: Tuple = args[i];
      nextScopeVariables.set(argName, argValue);
    }
    var operation: Array<Operation> = Reflect.callMethod(null, fn.fn, InvokeFunction.getHaxeArgs(this.args, nextScopeVariables));
    var annaCallStack: AnnaCallStack = new AnnaCallStack(operation, nextScopeVariables);
    processStack.add(annaCallStack);
  }
}