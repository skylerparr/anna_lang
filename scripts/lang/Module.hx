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

  public static function define(moduleSpec: ModuleSpec): Atom {
    moduleSpecMap.set(moduleSpec.moduleName, moduleSpec);
    return 'ok'.atom();
  }

  public static function getModule(module: Atom): ModuleSpec {
    return moduleSpecMap.get(module);
  }

}