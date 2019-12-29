package vm;

import util.ArgHelper;
import EitherEnums.Either2;
import lang.EitherSupport;
import vm.Function;
import vm.Operation;
class PushStack implements Operation {

  public var module: Atom;
  public var func: Atom;
  public var args: LList;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function new(module: Atom, func: Atom, args: LList, hostModule: Atom, hostFunction: Atom, line: Int) {
    this.module = module;
    this.func = func;
    this.args = args;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = line;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    Logger.log('get function');
    Logger.log(module);
    Logger.log(func);
    var fn: Function = Classes.getFunction(module, func);
    if(fn == null) {
      Logger.inspect('Function not found ${module.toAnnaString()} ${func.toAnnaString()}');
      Kernel.crash(Process.self());
      return;
    }
    Logger.log("here");
    var counter: Int = 0;
    var callArgs: Array<Dynamic> = [];
    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(arg in LList.iterator(args)) {
      var value: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables);
      callArgs.push(value);
      var argName: String = fn.args[counter++];
      nextScopeVariables.set(argName, value);
    }
    callArgs.push(nextScopeVariables);
    Logger.log(callArgs);
    var operations: Array<Operation> = fn.invoke(callArgs);
    if(operations == null) {
      Kernel.crash(Process.self());
      return;
    }
    var annaCallStack: AnnaCallStack = new DefaultAnnaCallStack(operations, nextScopeVariables);
    processStack.add(annaCallStack);
  }

  public function isRecursive(): Bool {
    var apiFunc: Atom = Classes.getApiFunction(this.module, this.func);
    return this.module == this.hostModule && apiFunc == this.hostFunction;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}