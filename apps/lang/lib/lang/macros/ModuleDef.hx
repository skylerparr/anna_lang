package lang.macros;

import haxe.macro.Expr;
class ModuleDef {
  public var moduleName: String;
  public var aliases: Map<String, String>;
  public var declaredFunctions: Map<String, Array<Dynamic>>;
  public var constants: Map<String, String>;
  public var interfaces: Array<String>;
  public var codeString: String;
  public var pack: String;
  public var extend: String;

  public function new(moduleName: String) {
    this.moduleName = moduleName;
    aliases = new Map<String, String>();
    declaredFunctions = new Map<String, Array<Dynamic>>();
    constants = new Map<String, String>();
    interfaces = [];
    pack = "";
    extend = "";
  }
}
