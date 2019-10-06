package util;

import EitherEnums.Either1;
import lang.EitherSupport;
import EitherEnums.Either2;
class ArgHelper {

  public static function extractArgValue(arg: Dynamic, scopeVariables: Map<String, Dynamic>): Dynamic {
    var tuple: Tuple = EitherSupport.getValue(arg);
    if(Std.is(tuple, Tuple)) {
      var argArray = tuple.asArray();
      if(argArray.length == 2) {
        var elem1: Either2<Atom, Dynamic> = argArray[0];
        var elem2: Either2<Atom, Dynamic> = argArray[1];

        return switch(cast(EitherSupport.getValue(elem1), Atom)) {
          case {value: 'const'}:
            var value = EitherSupport.getValue(elem2);
            if(Std.is(value, Tuple)) {
              resolveTupleValues(cast value, scopeVariables);
            } else {
              value;
            }
          case {value: 'var'}:
            var varName: String = EitherSupport.getValue(elem2);
            scopeVariables.get(varName);
          case _:
            Logger.inspect("!!!!!!!!!!! bad !!!!!!!!!!!");
            arg;
        }
      } else {
        return arg;
      }
    } else {
      return arg;
    }
  }

  public static function resolveTupleValues(tuple: Tuple, scopeVariables: Map<String, Dynamic>): Dynamic {
    var items: Array<Any> = tuple.asArray();
    for(i in 0...items.length) {
      var newValue = items[i];
      if(Type.getEnum(newValue) == Either2) {
        var fetched = extractArgValue(newValue, scopeVariables);
        items[i] = fetched;
      }
    }
    return Tuple.create(items);
  }

}