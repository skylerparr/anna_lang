package vm;

import EitherEnums.Either2;
import lang.EitherSupport;
class InvokeFunction implements Operation {
  public var func: Dynamic;
  public var args: LList;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public inline function new(func: Dynamic, args: LList, hostModule: Atom, hostFunction: Atom, line: Int) {
    this.func = func;
    this.args = args;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = line;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var args = getHaxeArgs(this.args, scopeVariables);
    var retVal: Dynamic = Reflect.callMethod(null, this.func, args);
    scopeVariables.set("$$$", retVal);
  }

  public static inline function getHaxeArgs(args: LList, scope: Map<String, Dynamic>): Array<Dynamic> {
    var functionArgs: Array<Dynamic> = [];

    for(arg in LList.iterator(args)) {
      var tuple: Tuple = EitherSupport.getValue(arg);
      var argArray = tuple.asArray();
      var elem1: Either2<Atom, Dynamic> = argArray[0];
      var elem2: Either2<Atom, Dynamic> = argArray[1];
      switch(cast(EitherSupport.getValue(elem1), Atom)) {
        case {value: 'const'}:
          functionArgs.push(EitherSupport.getValue(elem2));
        case {value: 'var'}:
          functionArgs.push(scope.get(EitherSupport.getValue(elem2)));
        case _:
          throw "AnnaLang: Unhandled case";
      }
    }
    return functionArgs;
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString() {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}