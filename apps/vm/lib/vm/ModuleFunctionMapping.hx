package vm;

interface ModuleFunctionMapping {
  function clear(): Void;
  function defineWithInstance(module: Atom, instance: Dynamic, funcs: Array<String>): Void;
  function define(module: Atom, classDef: Class<Dynamic>): Void;
  function defineFunction(moduleName: Atom, funcName: Atom, fun: Function): Void;
  function setIFace(interfaceModule: Atom, implModule: Atom): Void;
  function getFunction(moduleName: Atom, funName: Atom): Function;
  function getApiFunction(moduleName: Atom, funName: Atom): Atom;
  function exists(moduleName: Atom, funName: Atom): Bool;
  function getModules(): LList;
  function getApiFunctions(moduleName: Atom): LList;
  function getFunctions(moduleName: Atom): LList;
  function defined(moduleName: Atom): Atom;
}
