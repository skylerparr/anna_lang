package ;

import Reflect;
import lang.CustomTypes.CustomType;
import lang.ModuleSpec;
import haxe.ds.ObjectMap;
import compiler.CodeGen;
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
      case TObject:
        return inspectAtom((val : Atom));
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
    if(!Reflect.hasField(atom, '__type__')) {
      return 'unknown';
    }
    var capitals: EReg = ~/[A-Z]/;
    if(capitals.match(atom.value.charAt(0))) {
      return '${atom.value}';
    } else {
      return ':${atom.value}';
    }
  }

  private static inline function inspectArray(array: Array<Dynamic>): String {
    return array.asString();
  }

  private static inline function inspectCustomType(type: CustomType): String {
    return type.asString();
  }
}
