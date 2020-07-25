package vm;

import lang.ModuleNotFoundException;
import lang.macros.ModuleDef;
import lang.macros.AnnaLang;
import lang.AtomSupport;
using lang.AtomSupport;
using StringTools;
class Classes {

  public static var mapping: ModuleFunctionMapping = new BasicModuleFunctionMapping();

  public static function clear(): Void {
    mapping.clear();
  }

  public static function defineWithInstance(className: Atom, instance: Dynamic, funcs: Array<String>): Void {
    mapping.defineWithInstance(className, instance, funcs);
  }

  public static inline function define(moduleName: Atom, classDef: Class<Dynamic>): Void {
    mapping.define(moduleName, classDef);
  }

  public static function defineFunction(moduleName: Atom, funName: Atom, fun: Function): Void {
    mapping.defineFunction(moduleName, funName, fun);
  }

  public static function setIFace(interfaceModule: Atom, implModule: Atom): Void {
    mapping.setIFace(interfaceModule, implModule);
  }

  /**
   * Gets the true function to be executed. Must be the fully qualified function name
   * 
   * @param module atom
   * @param fully qualified function atom
   */
  public static inline function getFunction(moduleName: Atom, funName: Atom): Function {
    return mapping.getFunction(moduleName, funName);
  }

  /**
   * Gets the api function based on the fully qualified function name
   * the Api function is the pure function name with no reference to types
   *
   * @param module atom
   * @param fully qualified function atom
   */
  public static inline function getApiFunction(moduleName: Atom, funName: Atom): Atom {
    return mapping.getApiFunction(moduleName, funName);
  }

  public static inline function exists(moduleName: Atom, funName: Atom): Bool {
    return mapping.exists(moduleName, funName);
  }

  public static inline function getModules(): LList {
    return mapping.getModules();
  }

  public static inline function getApiFunctions(moduleName: Atom): LList {
    return mapping.getApiFunctions(moduleName);
  }

  public static inline function getFunctions(moduleName: Atom): LList {
    return mapping.getFunctions(moduleName);
  }

  public static inline function defined(moduleName: Atom): Atom {
    return mapping.defined(moduleName);
  }
}
