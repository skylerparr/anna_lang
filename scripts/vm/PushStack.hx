package vm;

import haxe.crypto.Sha256;
import util.StringUtil;
import lang.EitherSupport;
import EitherEnums.Either2;
import vm.Classes.Function;
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
    var fn: Function = Classes.getFunction(module, func);
    if(fn == null) {
      //TODO: handle missing function error
      Logger.inspect('throw a crazy error and kill the process!');
      return;
    }
    var counter: Int = 0;
    var callArgs: Array<Dynamic> = [];
    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(arg in LList.iterator(args)) {
      var tuple: Tuple = EitherSupport.getValue(arg);
      var argArray = tuple.asArray();
      var elem1: Either2<Atom, Dynamic> = argArray[0];
      var elem2: Either2<Atom, Dynamic> = argArray[1];

      var value: Dynamic = switch(cast(EitherSupport.getValue(elem1), Atom)) {
        case {value: 'const'}:
          EitherSupport.getValue(elem2);
        case {value: 'var'}:
          var varName: String = EitherSupport.getValue(elem2);
          scopeVariables.get(varName);
        case _:
          Logger.inspect("!!!!!!!!!!! bad !!!!!!!!!!!");
          null;
      }
      callArgs.push(value);
      var argName: String = fn.args[counter++];
      nextScopeVariables.set(argName, value);
    }
    callArgs.push(nextScopeVariables);
    var operations: Array<Operation> = Reflect.callMethod(null, fn.fn, callArgs);
    if(operations == null) {
      //TODO: handle missing function error
      Logger.inspect('operations is null!');
      return;
    }
    var annaCallStack: AnnaCallStack = new AnnaCallStack(operations, nextScopeVariables);
    processStack.add(annaCallStack);
  }

  public function isRecursive(): Bool {
    return this.module == this.hostModule && this.func == this.hostFunction;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}