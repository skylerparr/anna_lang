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

    var moduleSpec: ModuleSpec = new ModuleSpec("Foo".atom(), []);
    Module.define(moduleSpec);

    Assert.isNotNull(Module.getModule("Foo".atom()));
    Assert.areEqual(Module.getModule("Foo".atom()), moduleSpec);
  }
}