package vm;

import lang.macros.AnnaLang;
import hscript.Macro;
import haxe.macro.Expr.TypeDefinition;
import lang.macros.MacroContext;
import ArgHelper;
import EitherEnums.Either2;
import lang.EitherSupport;
import vm.Function;
import vm.Operation;
class PushStack implements Operation {

//  public static var typeDef: TypeDefinition = {kind: TDStructure, pos: Lang.annaLang.macroContext.currentPos(), fields: [], pack: [], name: ''};

  public var module: Atom;
  public var func: Atom;
  public var args: LList;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;
  public var annaLang: AnnaLang;

  public function new(module: Atom, func: Atom, args: LList, hostModule: Atom, hostFunction: Atom, line: Int, annaLang: AnnaLang) {
    this.module = module;
    this.func = func;
    this.args = args;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = line;
    this.annaLang = annaLang;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var fn: Function = Classes.getFunction(module, func);
    if(fn == null) {
      Logger.inspect('PushStack: Function not found ${module.toAnnaString()} ${func.toAnnaString()}:${lineNumber}');
      IO.inspect('PushStack: Function not found ${module.toAnnaString()} ${func.toAnnaString()}:${lineNumber}');
      Kernel.crash(Process.self());
      return;
    }
    var counter: Int = 0;
    var callArgs: Array<Dynamic> = [];
    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(arg in LList.iterator(args)) {
      var value: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables, annaLang);
      callArgs.push(value);
      var argName: String = fn.args[counter++];
      nextScopeVariables.set(argName, value);
    }
    callArgs.push(nextScopeVariables);
    var operations: Array<Operation> = fn.invoke(callArgs);
    if(operations == null) {
      IO.inspect('Function ${module.toAnnaString()} ${func.toAnnaString()}:${lineNumber} has no body.');
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