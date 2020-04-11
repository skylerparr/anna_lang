package ;

import lang.UserDefinedType;
import lang.macros.AnnaLang;
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

  public static inline function extractArgValue(arg: Dynamic, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): Dynamic {
    var tuple: Tuple = EitherSupport.getValue(arg);
    var retVal: Dynamic = arg;

    if(Std.is(tuple, Tuple)) {
      var argArray = Tuple.array(tuple);
      if(argArray.length == 2) {
        var elem1 = argArray[0];
        var elem2 = argArray[1];

        retVal = switch(cast(EitherSupport.getValue(elem1), Atom)) {
          case {value: 'const'}:
            var value = EitherSupport.getValue(elem2);
            if(Std.is(value, Tuple)) {
              resolveTupleValues(cast value, scopeVariables, annaLang);
            } else if(Std.is(value, LList)) {
              resolveListValues(cast value, scopeVariables, annaLang);
            } else if(Std.is(value, MMap)) {
              resolveMapValues(cast value, scopeVariables, annaLang);
            } else if(Std.is(value, Keyword)) {
              resolveKeywordValues(cast value, scopeVariables, annaLang);
            } else if(Std.is(value, AbstractCustomType)) {
              resolveAbstractCustomTypeValues(cast value, scopeVariables, annaLang);
            } else {
              value;
            }
          case {value: 'var'}:
            var varName: String = EitherSupport.getValue(elem2);
            var value: Dynamic = scopeVariables.get(varName);
            if(value == null) {
              value = annaLang.macroContext.currentModuleDef.constants.get(varName);
            }
            value;
          case e:
            arg;
        }
      } else if(argArray.length == 3) {
        var elem2: String = argArray[1];
        var elem3: String = argArray[2];

        var customType: UserDefinedType = scopeVariables.get(elem2);
        retVal = customType.getField(elem3);
      }
    }
    return retVal;
  }

  public static inline function resolveTupleValues(tuple: Tuple, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): Tuple {
    var retVal: Array<Any> = [];
    var tupArr = Tuple.array(tuple);
    for(i in 0...tupArr.length) {
      var newValue = tupArr[i];
      var fetched = extractArgValue(newValue, scopeVariables, annaLang);
      retVal[i] = fetched;
    }
    return Tuple.create(retVal);
  }

  public static inline function resolveListValues(list: LList, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): LList {
    var values: Array<Any> = [];
    for(item in LList.iterator(list)) {
      var fetched = extractArgValue(item, scopeVariables, annaLang);
      values.push(fetched);
    }
    return LList.create(values);
  }

  public static inline function resolveMapValues(map: MMap, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): MMap {
    var retMap: Array<Tuple> = [];
    for(key in LList.iterator(MMap.keys(map))) {
      var item = MMap.get(map, key);
      var fetched: Dynamic = extractArgValue(item, scopeVariables, annaLang);
      var newKey: Dynamic = extractArgValue(key, scopeVariables, annaLang);
      retMap.push(newKey);
      retMap.push(fetched);
    }
    return MMap.create(retMap);
  }

  public static inline function resolveKeywordValues(keyword: Keyword, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): Keyword {
    var values: Array<Array<Any>> = [];
    for(kvPair in keyword.asArray()) {
      var key: Atom = cast Tuple.elem(kvPair, 0);
      var value = extractArgValue(Tuple.elem(kvPair, 1), scopeVariables, annaLang);
      values.push([key.value, value]);
    }
    return Keyword.create(values);
  }

  public static inline function resolveAbstractCustomTypeValues(value: lang.UserDefinedType, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): AbstractCustomType {
    var obj = {};
    for(field in UserDefinedType.fields(value)) {
      Reflect.setField(obj, field, extractArgValue(value.getField(field), scopeVariables, annaLang));
    }
    return UserDefinedType.create(value.__type, obj, annaLang);
  }

  public static inline function __updateScope(match: Map<String, Dynamic>, scope: Map<String, Dynamic>): Void {
    for(key in match.keys()) {
      scope.set(key, match.get(key));
    }
  }

}