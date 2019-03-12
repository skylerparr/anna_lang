package lang;

using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class Module {
  @field public static var moduleSpecMap: Map<Atom, ModuleSpec>;

  public static function start(): Void {
    if(moduleSpecMap == null) {
      moduleSpecMap = new Map<Atom, ModuleSpec>();
    }
  }

  public static function stop(): Void {
    moduleSpecMap = null;
  }

  public static function define(moduleSpec: ModuleSpec): Atom {
    moduleSpecMap.set(moduleSpec.module_name, moduleSpec);
    return 'ok'.atom();
  }

  public static function getModule(module: Atom): ModuleSpec {
    return moduleSpecMap.get(module);
  }

  public static function modulesDefined(): Array<ModuleSpec> {
    var retVal: Array<ModuleSpec> = [];
    for(m in moduleSpecMap) {
      retVal.push(m);
    }
    return retVal;
  }

}