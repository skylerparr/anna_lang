package vm;

import lang.AtomSupport;
using lang.AtomSupport;
using StringTools;

@:build(lang.macros.ValueClassImpl.build())
class Classes {

  @field public static var classes: Map<Atom, Class<Dynamic>>;
  @field public static var functions: Map<Atom, Map<Atom, Function>>;

  private static inline var PREFIX: String = '___';
  private static inline var SUFFIX: String = '_args';

  public static function clear(): Void {
    classes = null;
    functions = null;
  }

  public static inline function define(className: Atom, classDef: Class<Dynamic>): Void {
    if(classes == null) {
      classes = new Map<Atom, Class<Dynamic>>();
    }
    classes.set(className, classDef);

    if(functions == null) {
      functions = new Map<Atom, Map<Atom, Function>>();
    }
    var funMap: Map<Atom, Function> = functions.get(className);
    if(funMap == null) {
      funMap = new Map<Atom, Function>();
    }
    var funcs: Array<Dynamic> = Type.getClassFields(classDef);
    for(fun in funcs) {
      if(StringTools.startsWith(fun, PREFIX)) {
        var origFnName: String = StringTools.replace(fun, PREFIX, '');
        origFnName = StringTools.replace(origFnName, SUFFIX, '');
        var origFnAtom: Atom = origFnName.atom();
        var classFunctions: Map<Atom, Function> = functions.get(className);
        if(classFunctions == null) {
          classFunctions = new Map<Atom, Function>();
        }
        var fn: Function = classFunctions.get(origFnAtom);
        if(fn == null) {
          fn = {fn: null, args: null};
        }
        var argFun: Dynamic = Reflect.field(classDef, fun);
        var args: Array<String> = Reflect.callMethod(classDef, argFun, []);
        fn.args = args;
        classFunctions.set(origFnAtom, fn);
        functions.set(className, classFunctions);
      } else {
        var origFnAtom: Atom = cast(fun, String).atom();
        var classFunctions: Map<Atom, Function> = functions.get(className);
        if(classFunctions == null) {
          classFunctions = new Map<Atom, Function>();
        }
        var fn: Function = classFunctions.get(origFnAtom);
        if(fn == null) {
          fn = {fn: null, args: null};
        }
        fn.fn = Reflect.field(classDef, fun);
        classFunctions.set(origFnAtom, fn);
        functions.set(className, classFunctions);
      }
    }
  }

  public static inline function getClass(name: Atom): Class<Dynamic> {
    return classes.get(name);
  }

  public static inline function getFunction(className: Atom, funName: Atom): Function {
    var funMap: Map<Atom, Dynamic> = functions.get(className);
    if(funMap != null) {
      return funMap.get(funName);
    }
    return null;
  }
}

typedef Function = {
  fn: Dynamic,
  args: Array<String>
}