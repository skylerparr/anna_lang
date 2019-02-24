package ;

import Reflect;
import lang.CustomTypes.CustomType;
import haxe.ds.ObjectMap;
import compiler.Compiler;
import haxe.macro.Expr;
import hscript.Interp;
import hscript.Parser;
using TypePrinter.StringPrinter;
using TypePrinter.MapPrinter;
using TypePrinter.ArrayPrinter;
using TypePrinter.CustomTypePrinter;
using lang.AtomSupport;
using StringTools;
@:build(macros.ValueClassImpl.build())
class Anna {
  @field public static var parser: Parser;
  @field public static var interp: Interp;

  public static function start():Atom {
    parser = Native.callStaticField('Main', 'parser');
    interp = Native.callStaticField('Main', 'interp');
    Compiler.start();
    return 'ok'.atom();
  }

  public static function add(a: Int, b: Int): Int {
    return a + b;
  }

  public static function subtract(a: Int, b: Int): Int {
    return a - b;
  }

  public static function rem(a: Int, b: Int): Int {
    return a % b;
  }

  public static function inspect(val: Any): String {
    switch(Type.typeof(val)) {
      case TClass(String):
        return inspectString((val : String));
      case TClass(haxe.ds.ObjectMap):
        return inspectMap((val : ObjectMap<Dynamic, Dynamic>));
      case TClass(Array):
        return inspectArray(val);
      case TClass(Atom):
        return inspectAtom((val : Atom));
      case TObject:
        return inspectDynamic(val);
      case TInt | TFloat:
        return val;
      case TBool:
        return '${(val : Bool)}';
      case TNull:
        return 'nil';
      case TEnum(_) | TFunction | TUnknown:
        return '${val}';
      case _:
        return inspectCustomType(val);
    }
    return '';
  }

  private static inline function inspectString(string: String): String {
    return string.asString();
  }

  private static inline function inspectMap(map: ObjectMap<Dynamic, Dynamic>): String {
    return map.asString();
  }

  private static inline function inspectAtom(atom: Atom): String {
    var value: String = atom.value;
    switch(value) {
      case 'nil' | 'true' | 'false':
      case _:
        var capitals: EReg = ~/[A-Z]/;
        if(!capitals.match(value.charAt(0))) {
          value = ':${value}';
        }
    }
    return value;
  }

  private static inline function inspectDynamic(dyn: Dynamic): String {
    var kv: Array<String> = [];
    var keys: Array<String> = [];
    for(field in Reflect.fields(dyn)) {
      keys.push(field);
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
      var value: Dynamic = Reflect.field(dyn, key);
      kv.push('${inspect(key)} => ${inspect(value)}');
    }
    return '[ ${kv.join(', ')} ]';
  }

  private static inline function inspectArray(array: Array<Dynamic>): String {
    return array.asString();
  }

  private static inline function inspectCustomType(type: CustomType): String {
    return type.asString();
  }
}
