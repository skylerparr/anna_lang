package lang;

import lang.CustomTypes.CustomType;
import TypePrinter.CustomTypePrinter;
using lang.AtomSupport;

class ModuleSpec implements CustomType {
  public var module_name(default, never): Atom;
  public var functions(default, never): Array<FunctionSpec>;
  public var class_name(default, never): Atom;
  public var package_name(default, never): Atom;

  public static var nil: ModuleSpec = new ModuleSpec('nil'.atom(), [], 'nil'.atom(), 'nil'.atom());

  public inline function new(moduleName: Atom, functions: Array<FunctionSpec>, className: Atom, packageName: Atom) {
    Reflect.setField(this, 'module_name', moduleName);
    Reflect.setField(this, 'functions', functions);
    Reflect.setField(this, 'class_name', className);
    Reflect.setField(this, 'package_name', packageName);
  }

  public function toString(): String {
    return Anna.inspect(this);
  }

  public function toAnnaString(): String {
    return CustomTypePrinter.asString(this);
  }

  public function toHaxeString(): String {
    return 'new ModuleSpec(${Anna.toHaxeString(module_name)}, ${Anna.toHaxeString(functions)}, ${Anna.toHaxeString(class_name)}, ${Anna.toHaxeString(package_name)})';
  }

  public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
    return '';
  }
}