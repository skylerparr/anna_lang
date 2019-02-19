package lang;

import lang.CustomTypes.CustomType;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class ModuleSpec implements CustomType {
  public var moduleName: Atom;
  public var functions: Array<FunctionSpec>;

  public inline function new(moduleName: Atom, functions: Array<FunctionSpec>) {
    this.moduleName = moduleName;
    this.functions = functions;
  }

}