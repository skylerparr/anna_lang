package tests;
import anna_unit.Assert;
import lang.Module;
using lang.AtomSupport;
import lang.ModuleSpec;
@:build(macros.ScriptMacros.script())
class ModuleTest {

  public static function setup(): Void {
    Module.stop();
    Module.start();
  }

  public static function shouldStoreModuleSpec(): Void {
    Assert.isNull(Module.getModule("Foo".atom()));

    var moduleSpec: ModuleSpec = new ModuleSpec("Foo".atom(), [], 'nil'.atom(), 'nil'.atom());
    Module.define(moduleSpec);

    Assert.isNotNull(Module.getModule("Foo".atom()));
    Assert.areEqual(Module.getModule("Foo".atom()), moduleSpec);
  }

  public static function shouldGetAllDefinedModules(): Void {
    var moduleSpec1: ModuleSpec = new ModuleSpec("Foo".atom(), [], 'nil'.atom(), 'nil'.atom());
    Module.define(moduleSpec1);

    var moduleSpec2: ModuleSpec = new ModuleSpec("Bar".atom(), [], 'nil'.atom(), 'nil'.atom());
    Module.define(moduleSpec2);

    var allModules: Array<ModuleSpec> = Module.modulesDefined();
    allModules.sort(function(a: ModuleSpec, b: ModuleSpec): Int {
      if(a.moduleName.value < b.moduleName.value) return 1;
      if(a.moduleName.value > b.moduleName.value) return -1;
      return 0;
    });
    Assert.areEqual(moduleSpec1, allModules[0]);
    Assert.areEqual(moduleSpec2, allModules[1]);
  }
}