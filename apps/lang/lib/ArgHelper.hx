package ;

import lang.AbstractCustomType;
import lang.EitherSupport;
import lang.macros.AnnaLang;
import lang.UserDefinedType;
import vm.AnonFn;
class ArgHelper {

  public static inline function extractArgValue(arg: Dynamic, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): Dynamic {
    var argValue = EitherSupport.getValue(arg);
    var retVal: Dynamic = arg;

    #if scriptable
    if(Std.is(argValue, Tuple)) {
    #else
    if(cast(argValue, Tuple) != null) {
    #end
      var argArray = Tuple.array(argValue);
      if(argArray.length == 2) {
        var elem1 = argArray[0];
        var elem2 = argArray[1];

        retVal = switch(cast(EitherSupport.getValue(elem1), Atom)) {
          case {value: 'const'}:
            var value = EitherSupport.getValue(elem2);
          #if scriptable
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
          #else
            // Going for speed here. Minimizing the casts as best as possible
            var t: Tuple = cast value;
            if(t != null) {
              resolveTupleValues(t, scopeVariables, annaLang);
            } else {
              var l: LList = cast value;
              if(l != null) {
                resolveListValues(l, scopeVariables, annaLang);
              } else {
                var m: MMap = cast value;
                if(m != null) {
                  resolveMapValues(m, scopeVariables, annaLang);
                } else {
                  var k: Keyword = cast value;
                  if(k != null) {
                    resolveKeywordValues(k, scopeVariables, annaLang);
                  } else {
                    var u: UserDefinedType = cast value;
                    if(u != null) {
                      resolveAbstractCustomTypeValues(u, scopeVariables, annaLang);
                    } else {
                      value;
                    }
                  }
                }
              }
            }

          #end
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
        if(argArray[0] == Atom.create("field")) {
          var elem2: String = cast argArray[1];
          var elem3: String = cast argArray[2];
          var customType: UserDefinedType = scopeVariables.get(elem2);
          if(customType == null) {
            var module: Atom = Atom.create(elem2);
            var funAtom: Atom = Atom.create(elem3);

            var exists = vm.Classes.exists(module, funAtom);
            if(exists) {
              var anonFn: AnonFn = new AnonFn();
              anonFn.module = Atom.create(elem2);
              anonFn.func = elem3;
              anonFn.annaLang = annaLang;
              anonFn.scope = scopeVariables;
              anonFn.apiFunc = Atom.create(elem3);
              retVal = anonFn;
            } else {
              retVal = arg;
            }
          } else {
            retVal = customType.getField(elem3);
          }
        }
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
    var retVal: LList = LList.create([]);
    for(item in LList.iterator(list)) {
      var fetched = extractArgValue(item, scopeVariables, annaLang);
      LList.add(retVal, fetched);
    }
    return retVal;
  }

  public static inline function resolveMapValues(map: MMap, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): MMap {
    var retMap: MMap = MMap.create([]);
    for(key in LList.iterator(MMap.keys(map))) {
      var item = MMap.get(map, key);
      var fetched: Dynamic = extractArgValue(item, scopeVariables, annaLang);
      var newKey: Dynamic = extractArgValue(key, scopeVariables, annaLang);
      MMap.put(retMap, newKey, fetched);
    }
    return retMap;
  }

  public static inline function resolveKeywordValues(keyword: Keyword, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): Keyword {
    var retKey: Keyword = Keyword.create([]);
    for(kvPair in keyword.asArray()) {
      var key: Atom = cast Tuple.elem(kvPair, 0);
      var value = extractArgValue(Tuple.elem(kvPair, 1), scopeVariables, annaLang);
      Keyword.add(retKey, key, value);
    }
    return retKey;
  }

  public static inline function resolveAbstractCustomTypeValues(value: lang.UserDefinedType, scopeVariables: Map<String, Dynamic>, annaLang: AnnaLang): AbstractCustomType {
    var obj = {};
    for(field in UserDefinedType.rawFields(value)) {
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
