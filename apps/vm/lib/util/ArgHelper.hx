package util;

import haxe.ds.EnumValueMap;
import EitherEnums.Either1;
import lang.EitherSupport;
import EitherEnums.Either2;
class ArgHelper {

  public static function extractArgValue(arg: Dynamic, scopeVariables: Map<String, Dynamic>): Dynamic {
    var tuple: Tuple = EitherSupport.getValue(arg);
    var retVal: Dynamic = arg;
    if(Std.is(tuple, Tuple)) {
      var argArray = tuple.asArray();
      if(argArray.length == 2) {
        var elem1: Either2<Atom, Dynamic> = argArray[0];
        var elem2: Either2<Atom, Dynamic> = argArray[1];

        retVal = switch(cast(EitherSupport.getValue(elem1), Atom)) {
          case {value: 'const'}:
            var value = EitherSupport.getValue(elem2);
            if(Std.is(value, Tuple)) {
              resolveTupleValues(cast value, scopeVariables);
            } else if(Std.is(value, LList)) {
              resolveListValues(cast value, scopeVariables);
            } else if(Std.is(value, MMap)) {
              resolveMapValues(cast value, scopeVariables);
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
      }
    }
    return retVal;
  }

  public static inline function resolveTupleValues(tuple: Tuple, scopeVariables: Map<String, Dynamic>): Dynamic {
    var items: Array<Any> = tuple.asArray();
    for(i in 0...items.length) {
      var newValue = items[i];
      var fetched = extractArgValue(newValue, scopeVariables);
      items[i] = fetched;
    }
    return Tuple.create(items);
  }

  public static inline function resolveListValues(list: LList, scopeVariables: Map<String, Dynamic>): Dynamic {
    var values: Array<Any> = [];
    for(item in LList.iterator(list)) {
      var fetched = extractArgValue(item, scopeVariables);
      values.push(fetched);
    }
    return LList.create(values);
  }

  public static inline function resolveMapValues(map: MMap, scopeVariables: Map<String, Dynamic>): Dynamic {
    var retMap: EnumValueMap<Dynamic, Dynamic> = new EnumValueMap<Dynamic, Dynamic>();
    for(key in LList.iterator(MMap.keys(map))) {
      var item = MMap.get(map, key);
      var fetched = extractArgValue(item, scopeVariables);
      retMap.set(key, fetched);
    }
    return MMap.create(retMap);
  }

}