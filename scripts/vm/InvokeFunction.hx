package vm;

import EitherEnums.Either2;
import lang.EitherSupport;
class InvokeFunction implements Operation {
  public var func: Dynamic;
  public var args: LList;

  public inline function new(func: Dynamic, args: LList) {
    this.func = func;
    this.args = args;
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
      }
    }
    return functionArgs;
  }
}