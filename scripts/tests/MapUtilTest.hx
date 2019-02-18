package tests;

import haxe.ds.ObjectMap;
import anna_unit.Assert;
using lang.MapUtil;
using lang.AtomSupport;
using TypePrinter.MapPrinter;
@:build(macros.ScriptMacros.script())
class MapUtilTest {
  public static var emptyMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();

  public static function shouldConvertDynamicToObjectMap(): Void {
    var d: Dynamic = {};
    Assert.areEqual(d.toMap(), emptyMap);
  }

  public static function shouldConvertDynamicWithKeysToObjectMap(): Void {
    var d: Dynamic = {foo: 'bar', cat: 'baz'.atom()};
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('foo', 'bar');
    map.set('cat', 'baz'.atom());
    Assert.areEqual(d.toMap(), map);
  }

  public static function shouldConvertMapToHaxeDynamic(): Void {
    Assert.areEqual(emptyMap.toDynamic(), {});
  }

  public static function shouldConvertMapWithKeysToHaxeDynamic(): Void {
    var d: Dynamic = {foo: 'bar'.atom(), cat: 'baz'.atom()};
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('foo', 'bar'.atom());
    map.set('cat', 'baz'.atom());
    Assert.areEqual(map.toDynamic(), d);
  }
}