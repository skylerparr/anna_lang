package tests;

import haxe.Template;
import lang.ModuleSpec;
import haxe.ds.ObjectMap;
using lang.AtomSupport;

import anna_unit.Assert;
@:build(macros.ScriptMacros.script())
class AnnaTest {
  public static function shouldPrintString(): Void {
    Assert.stringsAreEqual(Anna.inspect('foo'), '"foo"');
  }

  public static function shouldPrintInt(): Void {
    Assert.stringsAreEqual(Anna.inspect(2341), '2341');
  }

  public static function shouldPrintFloat(): Void {
    Assert.stringsAreEqual(Anna.inspect(234.1), '234.1');
  }

  public static function shouldPrintNullAsNil(): Void {
    Assert.stringsAreEqual(Anna.inspect(null), 'nil');
  }

  public static function shouldPrintTrueAsTrue(): Void {
    Assert.stringsAreEqual(Anna.inspect(true), 'true');
  }

  public static function shouldPrintFalseAsFalse(): Void {
    Assert.stringsAreEqual(Anna.inspect(false), 'false');
  }

  public static function shouldPrintAtomWithColonAtTheBeginning(): Void {
    Assert.stringsAreEqual(Anna.inspect('hello'.atom()), ':hello');
  }

  public static function shouldNotPrintAtomWithColonAtTheBeginningIfStartsWithUppercaseLetter(): Void {
    Assert.stringsAreEqual(Anna.inspect('Hello.World'.atom()), 'Hello.World');
  }

  public static function shouldPrintEmptyArray(): Void {
    Assert.stringsAreEqual(Anna.inspect([]), '{}');
  }

  public static function shouldPrintDynamic(): Void {
    Assert.stringsAreEqual(Anna.inspect({}), '[  ]');
  }

  public static function shouldPrintArrayWithValues(): Void {
    var values: Array<Dynamic> = [348, 349.54, 'foo', 'bar'.atom(), 'Cat'.atom()];
    Assert.stringsAreEqual(Anna.inspect(values), '{348, 349.54, "foo", :bar, Cat}');
  }

  public static function shouldPrintEmptyMap(): Void {
    Assert.stringsAreEqual(Anna.inspect(new ObjectMap()), '%{}');
  }

  public static function shouldPrintMapWithMixedValues(): Void {
    var values: Array<Dynamic> = [348, 349.54, 'foo', 'bar'.atom(), 'Cat'.atom()];
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap();
    map.set('foo'.atom(), "bar");
    map.set('bar'.atom(), 234);
    map.set('cat'.atom(), values);
    Assert.stringsAreEqual(Anna.inspect(map), '%{:bar => 234, :cat => {348, 349.54, "foo", :bar, Cat}, :foo => "bar"}');
  }

  public static function shouldPrintCustomTypes(): Void {
    var moduleSpec: ModuleSpec = new ModuleSpec('taser'.atom(), [], 'nil'.atom(), 'nil'.atom());
    Assert.stringsAreEqual(Anna.inspect(moduleSpec), '%lang.ModuleSpec{:module_name => :taser, :functions => {}, :class_name => nil, :package_name => nil}');
  }

  public static function shouldPrintDynamicTypeToMap(): Void {
    var dyn: Dynamic = {foo: 'bar'.atom(), baz: 'cat'.atom()};
    Assert.stringsAreEqual(Anna.inspect(dyn), '[ "baz" => :cat, "foo" => :bar ]');
  }

  public static function shouldPrintBasicObject(): Void {
    var template: Template = Anna.createInstance(Template, ['']);
    Assert.areEqual(Anna.inspect(template), "#<haxe.Template>");
  }

  public static function shouldReturnValueIfNotNil(): Void {
    var val: Dynamic = new ObjectMap();
    Assert.areEqual(Anna.or(val, []), new ObjectMap());
    Assert.areEqual(Anna.or('nil'.atom(), []), []);
  }
}