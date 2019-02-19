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
    var keys: Array<Dynamic> = [];
    for(key in map.keys()) {
      keys.push(key);
    }
    keys.sort( function(a:Dynamic, b:Dynamic):Int {
      if(Std.is(a, Atom) && Std.is(b, Atom)) {
        if (a.value < b.value) return -1;
        if (a.value > b.value) return 1;
      } else if(Std.is(a, String) && Std.is(b, String)) {
        if (a.toLowerCase() < b.toLowerCase()) return -1;
        if (a.toLowerCase() > b.toLowerCase()) return 1;
      } else {
        if (a < b) return -1;
        if (a > b) return 1;
      }
      return 0;
    });
    for(key in keys) {
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

class DynamicPrinter {
  public static function asString(obj: Dynamic): String {
    return '';
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