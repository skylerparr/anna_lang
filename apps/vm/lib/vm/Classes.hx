package vm;

import lang.ModuleNotFoundException;
import lang.macros.ModuleDef;
import lang.macros.AnnaLang;
import lang.AtomSupport;
using lang.AtomSupport;
using StringTools;
@:build(lang.macros.ValueClassImpl.build())
class Classes {

  @field public static var functions: Map<Atom, Map<Atom, Function>>;
  @field public static var apiFunctions: Map<Atom, Map<Atom, Atom>>;

  public static inline var PREFIX: String = '___';
  public static inline var SUFFIX: String = '_args';
  public static inline var API_PREFIX: String = '__api_';

  public static function clear(): Void {
    functions = null;
    apiFunctions = null;
  }

  public static function defineWithInstance(className: Atom, instance: Dynamic, funcs: Array<String>): Void {
    if(functions == null) {
      functions = new Map<Atom, Map<Atom, Function>>();
    }
    var funMap: Map<Atom, Function> = functions.get(className);
    if(funMap == null) {
      funMap = new Map<Atom, Function>();
    }
    if(apiFunctions == null) {
      apiFunctions = new Map<Atom, Map<Atom, Atom>>();
    }
    Lang.definedModules.set(className.value, instance);
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
        var args: Array<String> = Reflect.field(instance, fun);
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
        fn.fn = Reflect.field(instance, fun);
        classFunctions.set(origFnAtom, fn);
        functions.set(className, classFunctions);
      }
    }
  }

  public static inline function define(className: Atom, classDef: Class<Dynamic>): Void {
    var instance: Dynamic = Type.createInstance(classDef, []);
    var funcs: Array<String> = Type.getInstanceFields(classDef);
    defineWithInstance(className, instance, funcs);
  }

  public static function defineFunction(moduleName: Atom, funName: Atom, fun: Function): Void {
    var funMap: Map<Atom, Function> = null;
    if(functions.exists(moduleName)) {
      funMap = functions.get(moduleName);
    } else {
      funMap = new Map();
    }

    funMap.set(funName, fun);
    functions.set(moduleName, funMap);
  }

  public static function setIFace(interfaceModule: Atom, implModule: Atom): Void {
    var funMap: Map<Atom, Function> = functions.get(implModule);
    if(funMap == null) {
      throw new ModuleNotFoundException('AnnaLang: Unable to map module. ${Anna.toAnnaString(implModule)} not found.');
    }
    functions.set(interfaceModule, funMap);
    apiFunctions.set(interfaceModule, apiFunctions.get(implModule));
  }

  /**
   * Gets the true function to be executed. Must be the fully qualified function name
   * 
   * @param module atom
   * @param fully qualified function atom
   */
  public static inline function getFunction(moduleName: Atom, funName: Atom): Function {
    var funMap: Map<Atom, Function> = functions.get(moduleName);
    if(funMap != null) {
      return funMap.get(funName);
    }
    return null;
  }

  /**
   * Gets the api function based on the fully qualified function name
   * the Api function is the pure function name with no reference to types
   *
   * @param module atom
   * @param fully qualified function atom
   */
  public static inline function getApiFunction(moduleName: Atom, funName: Atom): Atom {
    var funMap: Map<Atom, Atom> = apiFunctions.get(moduleName);
    if(funMap != null) {
      return funMap.get(funName);
    }
    return null;
  }

  public static inline function getModules(): LList {
    var modules: Array<Atom> = [];
    for(module in functions.keys()) {
      modules.push(module); 
    }
    return LList.create(cast modules);
  }

  public static inline function getApiFunctions(moduleName: Atom): LList {
    var retVal: Array<Atom> = [];
    var funMap: Map<Atom, Atom> = apiFunctions.get(moduleName);
    if(funMap == null) {
      return LList.create([]); 
    }
    for(fun in funMap) {
      retVal.push(fun);
    }
    return LList.create(cast retVal);
  }

  public static inline function getFunctions(moduleName: Atom): LList {
    var retVal: Array<Atom> = [];
    var funMap: Map<Atom, Function> = functions.get(moduleName);
    if(funMap == null) {
      return LList.create([]);
    }
    for(fun in funMap.keys()) {
      retVal.push(fun);
    }
    return LList.create(cast retVal);
  }
}
