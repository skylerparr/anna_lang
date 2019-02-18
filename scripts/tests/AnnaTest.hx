package tests;

import lang.ModuleSpec;
import haxe.ds.ObjectMap;
using lang.AtomSupport;

import anna_unit.Assert;
@:build(macros.ScriptMacros.script())
class AnnaTest {
  public static function shouldPrintString(): Void {
    Assert.stringAreEqual(Anna.inspect('foo'), '"foo"');
  }

  public static function shouldPrintInt(): Void {
    Assert.stringAreEqual(Anna.inspect(2341), '2341');
  }

  public static function shouldPrintFloat(): Void {
    Assert.stringAreEqual(Anna.inspect(234.1), '234.1');
  }

  public static function shouldPrintNullAsNil(): Void {
    Assert.stringAreEqual(Anna.inspect(null), 'nil');
  }

  public static function shouldPrintTrueAsTrue(): Void {
    Assert.stringAreEqual(Anna.inspect(true), 'true');
  }

  public static function shouldPrintFalseAsFalse(): Void {
    Assert.stringAreEqual(Anna.inspect(false), 'false');
  }

  public static function shouldPrintAtomWithColonAtTheBeginning(): Void {
    Assert.stringAreEqual(Anna.inspect('hello'.atom()), ':hello');
  }

  public static function shouldNotPrintAtomWithColonAtTheBeginningIfStartsWithUppercaseLetter(): Void {
    Assert.stringAreEqual(Anna.inspect('Hello.World'.atom()), 'Hello.World');
  }

  public static function shouldPrintEmptyArray(): Void {
    Assert.stringAreEqual(Anna.inspect([]), '{}');
  }

  public static function shouldPrintDynamic(): Void {
    Assert.stringAreEqual(Anna.inspect({}), 'unknown');
  }

  public static function shouldPrintArrayWithValues(): Void {
    var values: Array<Dynamic> = [348, 349.54, 'foo', 'bar'.atom(), 'Cat'.atom()];
    Assert.stringAreEqual(Anna.inspect(values), '{348, 349.54, "foo", :bar, Cat}');
  }

  public static function shouldPrintEmptyMap(): Void {
    Assert.stringAreEqual(Anna.inspect(new ObjectMap()), '%{}');
  }

  public static function shouldPrintMapWithMixedValues(): Void {
    var values: Array<Dynamic> = [348, 349.54, 'foo', 'bar'.atom(), 'Cat'.atom()];
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap();
    map.set('foo'.atom(), "bar");
    map.set('bar'.atom(), 234);
    map.set('cat'.atom(), values);
    Assert.stringAreEqual(Anna.inspect(map), '%{:bar => 234, :cat => {348, 349.54, "foo", :bar, Cat}, :foo => "bar"}');
  }

  public static function shouldPrintCustomTypes(): Void {
    var moduleSpec: ModuleSpec = new ModuleSpec('taser'.atom());
    Assert.stringAreEqual(Anna.inspect(moduleSpec), '%lang.ModuleSpec{:moduleName => :taser}');
  }
}