package lang.macros;

class ModuleDef {
  public var moduleName: String;
  public var aliases: Map<String, String>;
  public var declaredFunctions: Map<String, Array<Dynamic>>;

  public function new(moduleName: String) {
    this.moduleName = moduleName;
    aliases = new Map<String, String>();
    declaredFunctions = new Map<String, Array<Dynamic>>();
  }


}