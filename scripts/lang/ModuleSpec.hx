package lang;

import lang.CustomTypes.CustomType;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class ModuleSpec implements CustomType {
  public var moduleName: Atom;
  public var functions: Array<FunctionSpec>;
  public var className: Atom;
  public var packageName: Atom;

  public inline function new(moduleName: Atom, functions: Array<FunctionSpec>, className: Atom, packageName: Atom) {
    this.moduleName = moduleName;
    this.functions = functions;
    this.className = className;
    this.packageName = packageName;
  }

}