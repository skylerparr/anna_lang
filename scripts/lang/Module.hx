package lang;

using lang.AtomSupport;

@:build(macros.ValueClassImpl.build())
class Module {
  @field public var moduleSpecMap: Map<Atom, ModuleSpec>;

  public static function start(): Void {
    if(moduleSpecMap == null) {
      moduleSpecMap = new Map<Atom, ModuleSpec>();
    }
  }

  public static function stop(): Void {
    moduleSpecMap = null;
  }

  public static function define(moduleSpec: ModuleSpec): Atom {
    moduleSpecMap.set(moduleSpec.moduleName, moduleSpec);
    return 'ok'.atom();
  }

  public static function getModule(module: Atom): ModuleSpec {
    return moduleSpecMap.get(module);
  }

  public static function moduleDefined(): Array<ModuleSpec> {
    var retVal: Array<ModuleSpec> = [];
    for(m in moduleSpecMap) {
      retVal.push(m);
    }
    return retVal;
  }

}