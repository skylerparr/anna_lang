package ;

import util.TimeUtil;
import haxe.Timer;
import String;
import project.DefaultProjectConfig;
import project.ProjectConfig;
import lang.CustomType;
import haxe.ds.ObjectMap;
import haxe.ds.EnumValueMap;
import haxe.macro.Expr;
import hscript.Interp;
import hscript.Parser;
import lang.EitherSupport;
import Reflect;
import TypePrinter.EnumMapPrinter;
import TypePrinter.MapPrinter;
import TypePrinter.StringMapPrinter;
using TypePrinter.StringPrinter;
using TypePrinter.MapPrinter;
using TypePrinter.ArrayPrinter;
using TypePrinter.CustomTypePrinter;
using TypePrinter.StringMapPrinter;
using lang.AtomSupport;
using StringTools;
using haxe.EnumTools;
using haxe.EnumTools.EnumValueTools;

@:build(lang.macros.ValueClassImpl.build())
class Anna {
  @field public static var parser: Parser;
  @field public static var interp: Interp;

  public static function compileProject(p: ProjectConfig): Array<String> {
    if(p == null) {
      cpp.Lib.println('No project file provided, doing nothing.');
      return [];
    }

    var startTime: Float = Timer.stamp();
    var files = Native.callStatic('Runtime', 'compileProject', [p]);
    if(files == null) {
      return ['Anna'];
    }
    var diff: Float = (Timer.stamp() - startTime) * 1000;
    cpp.Lib.println('Compilation Time: ${TimeUtil.getHumanTime(diff)}');
    return files;
  }

  public static function createInstance(type: Class<Dynamic>, constructorArgs: Array<Dynamic>): Dynamic {
    return Type.createInstance(type, constructorArgs);
  }

  public static function or(val: Dynamic, val2: Dynamic): Dynamic {
    if(val == 'nil'.atom()) {
      return val2;
    }
    return val;
  }

  public static inline function toHaxeString(val: Any): String {
    return {
      switch(Type.typeof(val)) {
        case TInt | TFloat:
          val;
        case TClass(Atom):
          '${((val : Atom).toHaxeString())}';
        case TClass(String):
          '"${val}"';
        case TClass(haxe.ds.ObjectMap):
          MapPrinter.asHaxeString((val : ObjectMap<Dynamic, Dynamic>));
        case TClass(haxe.ds.StringMap):
          StringMapPrinter.asHaxeString((val : Map<String, Dynamic>));
        case TClass(Array):
          '${val}';
        case TObject:
          inspectDynamic(val);
        case TBool:
          '${(val : Bool)}';
        case TNull:
          'nil';
        case TEnum(_) | TFunction | TUnknown:
          '${val}';
        case _:
          if(Std.is(val, CustomType)) {
            (val : CustomType).toHaxeString();
          } else {
            inspectObject(val);
          }
      }  
    }
  }

  public static inline function toAnnaString(val: Any): String {
    return {
      switch(Type.typeof(val)) {
        case TEnum(_):
          toAnnaString(EitherSupport.getValue(val));
        case TClass(Atom):
          '${((val : Atom).toAnnaString())}';
        case TInt | TFloat:
          val;
        case TClass(String):
          '"${val}"';
        case TClass(Tuple):
          (val : Tuple).toAnnaString();
        case TClass(MMap):
          (val : MMap).toAnnaString();
        case TClass(LList):
          (val : LList).toAnnaString();
        case TBool:
          '${(val : Bool)}';
        case TNull:
          'nil';
        case type:
          if(Std.is(val, CustomType)) {
            (val : CustomType).toAnnaString();
          } else {
            switch(type) {
              case TFunction | TUnknown:
                '${val}';
              case TObject:
                inspectDynamic(val);
              case TClass(Array):
                var retVal: Array<String> = [];
                for(v in (val : Array<Dynamic>)) {
                  retVal.push(Anna.toAnnaString(v));
                }
                "#A[" + retVal.join(', ') + "]";
              case TClass(haxe.ds.EnumValueMap):
                EnumMapPrinter.asAnnaString((val : EnumValueMap<Dynamic, Dynamic>));
              case TClass(haxe.ds.ObjectMap):
                MapPrinter.asAnnaString((val : ObjectMap<Dynamic, Dynamic>));
              case TClass(haxe.ds.StringMap):
                StringMapPrinter.asAnnaString((val : Map<String, Dynamic>));
              case _:
                inspectObject(val);
            }
          }
      }
    }
  }

  public static inline function toHaxePattern(val: Any, patternArgs: Array<KeyValue<String, String>> = null): String {
    return {
      switch(Type.typeof(val)) {
        case TClass(String):
          '"${val}"';
        case TClass(haxe.ds.ObjectMap):
          MapPrinter.asHaxeString((val : ObjectMap<Dynamic, Dynamic>));
        case TClass(haxe.ds.StringMap):
          StringMapPrinter.asHaxeString((val : Map<String, Dynamic>));
        case TClass(Array):
          '${val}';
        case TClass(Atom):
          '${((val : Atom).toPattern(patternArgs))}';
        case TObject:
          '${val}';
        case TInt | TFloat:
          val;
        case TBool:
          '${(val : Bool)}';
        case TNull:
          'nil';
        case TEnum(_) | TFunction | TUnknown:
          '${val}';
        case _:
          if(Std.is(val, CustomType)) {
            (val : CustomType).toPattern(patternArgs);
          } else {
            inspectObject(val);
          }
      }
    }
  }

  public static function inspect(val: Any): String {
    return toAnnaString(val);
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
      kv.push('${key}: ${toHaxeString(value)}');
    }
    return '{ ${kv.join(', ')} }';
  }

  public static function inspectObject(obj: Dynamic): String {
    var fqClassName: String = Type.getClassName(Type.getClass(obj));
    return '#<${fqClassName}>';
  }
}
