package;

import haxe.ds.EnumValueMap;
import util.StringUtil;
import lang.CustomTypes.CustomType;
import haxe.ds.ObjectMap;
using lang.AtomSupport;
class TypePrinter {

}

class StringMapPrinter {
  public static function asAnnaString(map: Map<String, Dynamic>): String {
    var kv: Array<String> = [];
    var keys: Array<Dynamic> = [];
    for(key in map.keys()) {
      keys.push(key);
    }
    keys.sort( function(a:String, b:String):Int {
      if (a.toLowerCase() < b.toLowerCase()) return -1;
      if (a.toLowerCase() > b.toLowerCase()) return 1;
      return 0;
    });
    for(key in keys) {
      var keyString: String = Anna.inspect(key);
      var value: Dynamic = map.get(key);
      var valueString = Anna.inspect(value);
      kv.push('${keyString} => ${valueString}');
    }
    return '#SM%{${kv.join(', ')}}';
  }

  public static function asHaxeString(map: Map<String, Dynamic>): String {
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
      var keyString: String = '';
      if(key == null) {
        key = 'nil'.atom();
      }
      if(Std.is(key, String)) {
        keyString = '"${key}"';
      } else {
        keyString = key.toString();
      }
      var value: Dynamic = map.get(key);
      var valueString: String = '';
      if(value == null) {
        value = 'nil'.atom();
      }
      if(Std.is(value, String)) {
        valueString = '"${value}"';
      } else {
        valueString = value.toString();
      }

      kv.push('${keyString} => ${valueString}');
    }
    return '[${kv.join(', ')}]';
  }
}

class EnumMapPrinter {
  public static function asAnnaString(map: EnumValueMap<Dynamic, Dynamic>): String {
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
    return '#EMP%{${kv.join(', ')}}';
  }
}

class MapPrinter {
  public static function asAnnaString(map: ObjectMap<Dynamic, Dynamic>): String {
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
    return '#M%{${kv.join(', ')}}';
  }

  public static function asHaxeString(map: ObjectMap<Dynamic, Dynamic>): String {
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
      var keyString: String = '';
      if(key == null) {
        key = 'nil'.atom();
      }
      if(Std.is(key, String)) {
        keyString = '"${key}"';
      } else {
        keyString = Anna.toHaxeString(key);
      }
      var value: Dynamic = map.get(key);
      var valueString: String = '';
      if(value == null) {
        value = 'nil'.atom();
      }
      if(Std.is(value, String)) {
        valueString = '"${value}"';
      } else {
        valueString = Anna.toHaxeString(value);
      }

      kv.push('${keyString} => ${valueString}');
    }
    return '[${kv.join(', ')}]';
  }
}

class StringPrinter {
  public static function asString(string: String): String {
    return '"${string}"';
  }

  public static function toString(string: String): String {
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
    typeName = StringUtil.capitalizePackage(typeName);

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