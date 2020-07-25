package ;

import Tuple.TupleInstance;
import EitherEnums;
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
import org.hxbert.BERT;
import org.hxbert.BERT.ErlangValue;
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

#if !macro
@:build(lang.macros.ValueClassImpl.build())
#end
class Anna {
  @field public static var parser: Parser;
  @field public static var interp: Interp;

  #if !macro
  public static function compileProject(p: ProjectConfig): Array<String> {
    if(p == null) {
      trace('No project file provided, doing nothing.');
      return [];
    }

    var startTime: Float = Timer.stamp();
    var files = Native.callStatic('Runtime', 'compileProject', [p]);
    if(files == null) {
      return ['Anna'];
    }
    var diff: Float = (Timer.stamp() - startTime) * 1000;
    trace('Compilation Time: ${TimeUtil.getHumanTime(diff)}');
    return files;
  }
  #end

  public static function or(val: Dynamic, val2: Dynamic): Dynamic {
    if(val == 'nil'.atom()) {
      return val2;
    }
    return val;
  }

  public static inline function termToBinary(term: Any): Binary {
    var bytes = {
      switch(Type.typeof(term)) {
        case TClass(Atom):
          var bertAtom = BERT.atom((term : Atom).value);
          BERT.encode(bertAtom);
        case TInt | TFloat | TClass(String):
          BERT.encode(term);
        case TClass(TupleInstance):
          var bert = (term : TupleInstance).asBert();
          BERT.encode(bert);
        case TClass(AnnaList_Any):
          var bert = (term : AnnaList_Any).asBert();
          BERT.encode(bert);
        case e:
          trace(e);
          BERT.encode(BERT.atom('nil')); 
      }
    }
    return new Binary(bytes);
  }

  public static inline function termToBert(term: Any): Dynamic {
    var retVal: Dynamic = {
      switch(Type.typeof(term)) {
        case TClass(Atom):
          BERT.atom((term : Atom).value);
        case TInt | TFloat | TClass(String) | TClass(Array):
          term;
        case TClass(TupleInstance):
          var tuple: TupleInstance = cast term;
          tuple.asBert();
        case TClass(AnnaList_Any):
          (term : AnnaList_Any).asBert();
        case e:
          trace(e);
          BERT.encode(BERT.atom('nil')); 
      }
    }
    return retVal;
  }
  
  public static inline function bertToTerm(value: Dynamic): Dynamic {
    var retVal: Dynamic = {
      switch(Type.typeof(value)) {
        case TObject:
          switch(value.type) {
            case ATOM:
              Atom.create(value.value);
            case TUPLE:
              Tuple.fromBert(value);
            case BINARY:
              Atom.create('nil');
            case BIG_INTEGER:
              Atom.create('nil');
            case MAP:
              Atom.create('nil');
          }
        case TClass(Array):
          var array: Array<Any> = cast value;
          var values: Array<Any> = [];
          for(v in array) {
            var val = bertToTerm(v);
            values.push(val);
          }
          LList.create(values);
        case e:
          value;
      }
    }
    return retVal;
  }
  
  public static inline function binaryToTerm(binary: Binary): Dynamic {
    var bert: Dynamic = BERT.decode(binary.getBytes(), true);
    var term = bertToTerm(bert);
    return term;
  }

  public static inline function toAnnaString(val: Any, gettingEnum: Bool = false, scopeVariables: Map<String, Dynamic> = null): String {
    return {
      switch(Type.typeof(val)) {
        case TEnum(e):
          if(gettingEnum) {
            '${val}';
          } else {
            toAnnaString(EitherSupport.getValue(val), true);
          }
        case TClass(Atom):
          '${((val : Atom).toAnnaString())}';
        case TInt | TFloat:
          val;
        case TClass(String):
          '"${StringTools.replace(val, '"', '\\\\"')}"';
        case TClass(Tuple):
          (val : TupleInstance).toAnnaString();
        case TClass(MMap):
          (val : MMap).toAnnaString();
        case TClass(LList):
          (val : LList).toAnnaString();
        case TBool:
          '${(val : Bool)}';
        case TNull:
          'null';
        case type:
          if(Std.is(val, CustomType)) {
            var retVal: String = (val : CustomType).toAnnaString();
            if(retVal == null) {
              retVal = '${type}';
            }
            retVal;
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
      kv.push('${key}: ${toAnnaString(value)}');
    }
    return '{${kv.join(', ')}}';
  }

  public static function inspectObject(obj: Dynamic): String {
    var fqClassName: String = Type.getClassName(Type.getClass(obj));
    return '#<${fqClassName}>';
  }
}
