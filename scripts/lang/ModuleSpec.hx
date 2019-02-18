package lang;

import lang.CustomTypes.CustomType;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class ModuleSpec implements CustomType {
  public var moduleName: Atom;

  public inline function new(moduleName: Atom) {
    this.moduleName = moduleName;
  }

}