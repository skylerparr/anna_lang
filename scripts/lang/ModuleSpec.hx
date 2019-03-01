package lang;

import lang.CustomTypes.CustomType;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class ModuleSpec implements CustomType {
  public var module_name(default, never): Atom;
  public var functions(default, never): Array<FunctionSpec>;
  public var class_name(default, never): Atom;
  public var package_name(default, never): Atom;

  public inline function new(moduleName: Atom, functions: Array<FunctionSpec>, className: Atom, packageName: Atom) {
    Reflect.setField(this, 'module_name', moduleName);
    Reflect.setField(this, 'functions', functions);
    Reflect.setField(this, 'class_name', className);
    Reflect.setField(this, 'package_name', packageName);
  }

  public function toString(): String {
    return Anna.inspect(this);
  }

}