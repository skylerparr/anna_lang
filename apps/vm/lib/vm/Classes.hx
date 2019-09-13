package vm;

using lang.AtomSupport;
using StringTools;

@:build(lang.macros.ValueClassImpl.build())
class Classes {

  @field public static var classes: Map<Atom, Class<Dynamic>>;
  @field public static var functions: Map<Atom, Map<Atom, Function>>;
  @field public static var instances: Map<Atom, Dynamic>;

  private static inline var PREFIX: String = '___';
  private static inline var SUFFIX: String = '_args';

  public static function clear(): Void {
    classes = null;
    functions = null;
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
          fn = {fn: null, args: null};
        }
        var args: Array<String> = Reflect.getProperty(instance, fun);
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
}

typedef Function = {
  fn: Dynamic,
  args: Array<String>
}