package ;

import lang.macros.MacroContext;
import vm.Process;
import EitherEnums.Either3;
import EitherEnums.Either2;
import EitherEnums.Either1;
import lang.AbstractCustomType;
import lang.CustomType;
import haxe.ds.EnumValueMap;
import lang.EitherSupport;
class ArgHelper {

  public static inline function extractArgValue(arg: Dynamic, scopeVariables: Map<String, Dynamic>): Dynamic {
    var tuple: Tuple = EitherSupport.getValue(arg);
    var retVal: Dynamic = arg;

    if(Std.is(tuple, Tuple)) {
      var argArray = tuple.asArray();
      if(argArray.length == 2) {
        var elem1 = argArray[0];
        var elem2 = argArray[1];

        retVal = switch(cast(EitherSupport.getValue(elem1), Atom)) {
          case {value: 'const'}:
            var value = EitherSupport.getValue(elem2);
            if(Std.is(value, Tuple)) {
              resolveTupleValues(cast value, scopeVariables);
            } else if(Std.is(value, LList)) {
              resolveListValues(cast value, scopeVariables);
            } else if(Std.is(value, MMap)) {
              resolveMapValues(cast value, scopeVariables);
            } else if(Std.is(value, Keyword)) {
              resolveKeywordValues(cast value, scopeVariables);
            } else if(Std.is(value, AbstractCustomType)) {
              resolveAbstractCustomTypeValues(cast value, scopeVariables);
            } else {
              value;
            }
          case {value: 'var'}:
            var varName: String = EitherSupport.getValue(elem2);
            var value: Dynamic = scopeVariables.get(varName);
            if(value == null) {
              value = MacroContext.currentModuleDef.constants.get(varName);
            }
            value;
          case e:
            arg;
        }
      }
    }
    return retVal;
  }

  public static inline function resolveTupleValues(tuple: Tuple, scopeVariables: Map<String, Dynamic>): Tuple {
    var items: Array<Any> = tuple.asArray();
    return buildTuple(items, scopeVariables);
  }

  public static inline function buildTuple(items: Array<Any>, scopeVariables: Map<String, Dynamic>): Tuple {
    for(i in 0...items.length) {
      var newValue = items[i];
      var fetched = extractArgValue(newValue, scopeVariables);
      items[i] = fetched;
    }
    return Tuple.create(items);
  }

  public static inline function resolveListValues(list: LList, scopeVariables: Map<String, Dynamic>): LList {
    var values: Array<Any> = [];
    for(item in LList.iterator(list)) {
      var fetched = extractArgValue(item, scopeVariables);
      values.push(fetched);
    }
    return LList.create(values);
  }

  public static inline function resolveMapValues(map: MMap, scopeVariables: Map<String, Dynamic>): MMap {
    var retMap: Array<Tuple> = [];
    for(key in LList.iterator(MMap.keys(map))) {
      var item = MMap.get(map, key);
      var fetched: Dynamic = extractArgValue(item, scopeVariables);
      var newKey: Dynamic = extractArgValue(key, scopeVariables);
      retMap.push(newKey);
      retMap.push(fetched);
    }
    return MMap.create(retMap);
  }

  public static function resolveKeywordValues(keyword: Keyword, scopeVariables: Map<String, Dynamic>): Keyword {
    var values: Array<Array<Any>> = [];
    for(kvPair in keyword.asArray()) {
      var key: Atom = cast Tuple.elem(kvPair, 0);
      var value = extractArgValue(Tuple.elem(kvPair, 1), scopeVariables);
      values.push([key.value, value]);
    }
    return Keyword.create(values);
  }

  public static inline function resolveAbstractCustomTypeValues(value: AbstractCustomType, scopeVariables: Map<String, Dynamic>): AbstractCustomType {
    if(value.variables != null) {
      var variables = value.variables;
      for(key in variables.keys()) {
        var arg: String = variables.get(key);
        var fetched = extractArgValue(Tuple.create([Atom.create('var'), arg]), scopeVariables);
        Reflect.setField(value, key, fetched);
      }
    }
    return value.clone();
  }

}