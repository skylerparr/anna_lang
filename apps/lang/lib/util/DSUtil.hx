package util;
@:build(lang.macros.Macros.build())
class DSUtil {

  public static inline function dynamicToMap(d: Dynamic):MMap {
    return parseToMap(d, @map[]);
  }

  private static inline function parseToMap(d:Dynamic, retVal:MMap):MMap {
    var fields = Reflect.fields(d);
    for(field in fields) {
      var value: Dynamic = Reflect.field(d, field);
      if(value == null) {
        retVal = MMap.put(retVal, field, Atom.create(@_'nil'));
      } else if(Std.is(value, Array)) {
        var list: LList = dynamicArrayToList(value);
        retVal = MMap.put(retVal, field, list);
      } else if(Std.is(value, String) || Std.is(value, Int) || Std.is(value, Float)) {
        retVal = MMap.put(retVal, field, value);
      } else {
        var map: MMap = dynamicToMap(value);
        retVal = MMap.put(retVal, field, map);
      }
    }
    return retVal;
  }

  public static inline function dynamicArrayToList(d:Array<Dynamic>):LList {
    return parseToList(d, @list[]);
  }

  public static inline function parseToList(d:Array<Dynamic>, retVal: LList):LList {
    for(value in d) {
      if(value == null) {
        retVal = LList.add(retVal, Atom.create(@_'nil'));
      } else if(Std.is(value, Array)) {
        var list: LList = dynamicArrayToList(value);
        retVal = LList.add(retVal, list);
      } else if(Std.is(value, String) || Std.is(value, Int) || Std.is(value, Float)) {
        retVal = LList.add(retVal, value);
      } else {
        var map: MMap = dynamicToMap(value);
        retVal = LList.add(retVal, map);
      }
    }
    return retVal;
  }

  public static inline function mmapToDynamic(data:MMap):Dynamic {
    return parseToDynamic(data, {});
  }

  private static inline function parseToDynamic(d:MMap, retVal:Dynamic):Dynamic {
    for(field in LList.iterator(MMap.keys(d))) {
      var value: Dynamic = MMap.get(d, field);
      if(value == null) {
        Reflect.setField(retVal, field, Atom.create(@_'nil'));
      } else if(Std.is(value, LList)) {
        var array: Array<Dynamic> = llistToDynamicArray(value);
        Reflect.setField(retVal, field, array);
      } else if(Std.is(value, String) || Std.is(value, Int) || Std.is(value, Float)) {
        Reflect.setField(retVal, field, value);
      } else {
        var dyn: Dynamic = mmapToDynamic(value);
        Reflect.setField(retVal, field, dyn);
      }
    }
    return retVal;
  }

  public static inline function llistToDynamicArray(data:LList):Array<Dynamic> {
    return parseToDynamicArray(data, []);
  }

  public static function parseToDynamicArray(data:LList, retVal:Array<Dynamic>):Array<Dynamic> {
    for(value in LList.iterator(data)) {
      if(value == null) {
        retVal.push(Atom.create(@_'nil'));
      } else if(Std.is(value, LList)) {
        var array: Array<Dynamic> = llistToDynamicArray(value);
        retVal.push(array);
      } else if(Std.is(value, String) || Std.is(value, Int) || Std.is(value, Float)) {
        retVal.push(value);
      } else {
        var dyn: Dynamic = mmapToDynamic(value);
        retVal.push(dyn);
      }
    }
    return retVal;
  }
}
