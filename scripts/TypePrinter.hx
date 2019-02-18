package;

import lang.CustomTypes.CustomType;
import haxe.ds.ObjectMap;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class TypePrinter {

}

class MapPrinter {
  public static function asString(map: ObjectMap<Dynamic, Dynamic>): String {
    var kv: Array<String> = [];
    for(key in map.keys()) {
      var keyString: String = Anna.inspect(key);
      var value: Dynamic = map.get(key);
      var valueString = Anna.inspect(value);
      kv.push('${keyString} => ${valueString}');
    }
    return '%{${kv.join(', ')}}';
  }
}

class StringPrinter {
  public static function asString(string: String): String {
    return '"${string}"';
  }
}

class ArrayPrinter {
  public static function asString(array: Array<Dynamic>): String {
    var retVal: Array<String> = [];
    for(val in array) {
      retVal.push(Anna.inspect(val));
    }
    return '{${retVal.join(', ')}}';
  }
}

class CustomTypePrinter {
  public static function asString(obj: CustomType): String {
    var kv: Array<String> = [];
    var typeName: String = Type.getClassName(Type.getClass(obj));
    var fields: Array<String> = Reflect.fields(obj);
    for(field in fields) {
      var keyString: String = Anna.inspect(field.atom());
      var value: Dynamic = Reflect.field(obj, field);
      var valueString = Anna.inspect(value);
      kv.push('${keyString} => ${valueString}');
    }
    return '%${typeName}{${kv.join(', ')}}';
  }
}