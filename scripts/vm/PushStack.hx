package vm;

import vm.Operation;
class PushStack implements Operation {

  public var module: Atom;
  public var func: Atom;
  public var args: Array<String>;

  public function new(module: Atom, func: Atom, args: Array<String>) {
    this.module = module;
    this.func = func;
    this.args = args;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var clazz: Class<Dynamic> = Classes.getClass(module);
    var operation: Array<Operation> = Reflect.getProperty(clazz, func.value);

    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(arg in args) {
      nextScopeVariables.set(arg, scopeVariables.get(arg));
    }
    var annaCallStack: AnnaCallStack = new AnnaCallStack(operation, nextScopeVariables);
    processStack.add(annaCallStack);
  }
}