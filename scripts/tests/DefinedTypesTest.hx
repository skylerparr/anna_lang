package tests;

import lang.TypeSpec;
import anna_unit.Assert;
import lang.Module;
import lang.DefinedTypes;

using lang.AtomSupport;
class DefinedTypesTest {

  public static function setup() {
    DefinedTypes.stop();
    DefinedTypes.start();
  }

  public static function shouldStoreTypeSpec(): Void {
    Assert.isNull(DefinedTypes.getType("Foo".atom()));

    var typeSpec: TypeSpec = new TypeSpec("Foo".atom(), [], 'nil'.atom(), 'nil'.atom());
    DefinedTypes.define(typeSpec);

    Assert.isNotNull(DefinedTypes.getType("Foo".atom()));
    Assert.areEqual(DefinedTypes.getType("Foo".atom()), typeSpec);
  }

  public static function shouldGetAllDefinedTypes(): Void {
    var typeSpec1: TypeSpec = new TypeSpec("Foo".atom(), [], 'nil'.atom(), 'nil'.atom());
    DefinedTypes.define(typeSpec1);

    var typeSpec2: TypeSpec = new TypeSpec("Bar".atom(), [], 'nil'.atom(), 'nil'.atom());
    DefinedTypes.define(typeSpec2);

    var allTypes: Array<TypeSpec> = DefinedTypes.typesDefined();
    allTypes.sort(function(a: TypeSpec, b: TypeSpec): Int {
      if(a.name.value < b.name.value) return 1;
      if(a.name.value > b.name.value) return -1;
      return 0;
    });
    Assert.areEqual(typeSpec1, allTypes[0]);
    Assert.areEqual(typeSpec2, allTypes[1]);
  }
}