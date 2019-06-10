package vm;

import lang.EitherSupport;
import EitherEnums.Either2;
class InvokeFunction implements Operation {
  public var func: Dynamic;
  public var args: Array<Tuple>;

  public inline function new(func: Dynamic, args: Array<Tuple>) {
    this.func = func;
    this.args = args;
  }

  public function execute(scopeVariables: Map<Tuple, Dynamic>, processStack: ProcessStack): Void {
    Reflect.callMethod(null, this.func, getHaxeArgs(this.args));
  }

  public static inline function getHaxeArgs(args: Array<Tuple>): Array<Dynamic> {
    var functionArgs: Array<Dynamic> = [];

    for(arg in args) {
      var argArray = arg.asArray();
      var elem1: Either2<Atom, Dynamic> = argArray[0];
      var elem2: Either2<Atom, Dynamic> = argArray[1];
      switch(cast(EitherSupport.getValue(elem1), Atom)) {
        case {value: 'const'}:
          functionArgs.push(EitherSupport.getValue(elem2));
      }
    }
    return functionArgs;
  }
}