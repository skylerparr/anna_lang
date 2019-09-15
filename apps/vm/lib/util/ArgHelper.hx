package util;

import lang.EitherSupport;
import EitherEnums.Either2;
class ArgHelper {

  public static inline function extractArgValue(arg: Dynamic, scopeVariables: Map<String, Dynamic>): Dynamic {
    var tuple: Tuple = EitherSupport.getValue(arg);
    var argArray = tuple.asArray();
    var elem1: Either2<Atom, Dynamic> = argArray[0];
    var elem2: Either2<Atom, Dynamic> = argArray[1];

    return switch(cast(EitherSupport.getValue(elem1), Atom)) {
      case {value: 'const'}:
        EitherSupport.getValue(elem2);
      case {value: 'var'}:
        var varName: String = EitherSupport.getValue(elem2);
        scopeVariables.get(varName);
      case _:
        Logger.inspect("!!!!!!!!!!! bad !!!!!!!!!!!");
        null;
    }
  }

}