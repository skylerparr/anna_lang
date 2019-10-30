package vm;

import lang.AtomSupport;
using lang.AtomSupport;
using StringTools;

@:build(lang.macros.ValueClassImpl.build())
class Classes {

  @field public static var classes: Map<Atom, Class<Dynamic>>;
  @field public static var functions: Map<Atom, Map<Atom, Function>>;
  @field public static var apiFunctions: Map<Atom, Map<Atom, Atom>>;
  @field public static var instances: Map<Atom, Dynamic>;

  private static inline var PREFIX: String = '___';
  private static inline var SUFFIX: String = '_args';
  private static inline var API_PREFIX: String = '__api_';

  public static function clear(): Void {
    classes = null;
    functions = null;
    instances = null;
    apiFunctions = null;
  }

  public static function getInstance(className: Atom): Dynamic {
    return instances.get(className);
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
    var instance: Dynamic = Type.createInstance(classDef, []);
    if(instances == null) {
      instances = new Map<Atom, Dynamic>();
    }
    instances.set(className, instance);
    if(apiFunctions == null) {
      apiFunctions = new Map<Atom, Map<Atom, Atom>>();
    }
    var funcs: Array<String> = Type.getInstanceFields(classDef);
    var funIndex: Int = 0;
    for(fun in funcs) {
      if(StringTools.startsWith(fun, PREFIX)) {
        var origFnName: String = StringTools.replace(fun, PREFIX, '');
        origFnName = StringTools.replace(origFnName, SUFFIX, '');
        origFnName = origFnName.substr(0, origFnName.length - 2);
        var origFnAtom: Atom = origFnName.atom();
        var classFunctions: Map<Atom, Function> = functions.get(className);
        if(classFunctions == null) {
          classFunctions = new Map<Atom, Function>();
        }
        var fn: Function = classFunctions.get(origFnAtom);
        if(fn == null) {
          fn = new SimpleFunction();
        }
        fn.cls = instance;
        var args: Array<String> = Reflect.getProperty(instance, fun);
        fn.args = args;
        classFunctions.set(origFnAtom, fn);
        functions.set(className, classFunctions);
      } else if(StringTools.startsWith(fun, API_PREFIX)) {
        var apiFun: String = StringTools.replace(fun, API_PREFIX, '');
        var apiFuncs: Array<Atom> = Reflect.field(instance, fun);
        if(apiFuncs == null) {
          continue;
        }
        var funcModMap: Map<Atom, Atom> = apiFunctions.get(className);
        if(funcModMap == null) {
          funcModMap = new Map<Atom, Atom>();
        }
        for(func in apiFuncs) {
          funcModMap.set(func, Atom.create(apiFun));
        }
        apiFunctions.set(className, funcModMap);
      } else {
        var origFnAtom: Atom = cast(fun, String).atom();
        var classFunctions: Map<Atom, Function> = functions.get(className);
        if(classFunctions == null) {
          classFunctions = new Map<Atom, Function>();
        }
        var fn: Function = classFunctions.get(origFnAtom);
        if(fn == null) {
          fn = new SimpleFunction();
        }
        fn.cls = instance;
        fn.fn = Reflect.field(instance, fun);
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

  public static inline function getApiFunction(className: Atom, funName: Atom): Atom {
    var funMap: Map<Atom, Atom> = apiFunctions.get(className);
    if(funMap != null) {
      return funMap.get(funName);
    }
    return null;
  }
}