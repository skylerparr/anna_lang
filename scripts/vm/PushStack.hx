package vm;

import lang.EitherSupport;
import EitherEnums.Either2;
import vm.Classes.Function;
import vm.Operation;
class PushStack implements Operation {

  public var module: Atom;
  public var func: Atom;
  public var args: LList;

  public function new(module: Atom, func: Dynamic, args: LList) {
    this.module = module;
    this.func = func;
    this.args = args;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var fn: Function = Classes.getFunction(module, func);
    if(fn == null) {
      //TODO: handle missing function error
      Logger.inspect('throw a crazy error and kill the process!');
      return;
    }
    var callArgs: Array<Dynamic> = [];
    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(arg in LList.iterator(args)) {
      var tuple: Tuple = EitherSupport.getValue(arg);
      Logger.inspect(tuple);
    }

//    for(i in 0...fn.args.length) {
//      var argName: String = fn.args[i];
//      var argValue: Tuple = args[i];
//
//      var argArray = argValue.asArray();
//      var elem1: Either2<Atom, Dynamic> = argArray[0];
//      var elem2: Either2<Atom, Dynamic> = argArray[1];
//      var varName: String = EitherSupport.getValue(elem2);
//      var value: Dynamic = switch(cast(EitherSupport.getValue(elem1), Atom)) {
//        case {value: 'const'}:
//          EitherSupport.getValue(elem2);
//        case {value: 'var'}:
//          scopeVariables.get(varName);
//        case _:
//          Logger.inspect("!!!!!!!!!!! bad !!!!!!!!!!!");
//          null;
//      }
//      callArgs.push(value);
//      nextScopeVariables.set(argName, value);
//    }
////    var callArgs: Array<Dynamic> = InvokeFunction.getHaxeArgs(this.args, nextScopeVariables);
    var operations: Array<Operation> = Reflect.callMethod(null, fn.fn, callArgs);
    var annaCallStack: AnnaCallStack = new AnnaCallStack(operations, nextScopeVariables);
    processStack.add(annaCallStack);
  }
}