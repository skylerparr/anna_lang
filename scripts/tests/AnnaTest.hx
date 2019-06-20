package tests;

import TypePrinter.CustomTypePrinter;
import lang.CustomTypes.CustomType;
import haxe.Template;
import haxe.ds.ObjectMap;
using lang.AtomSupport;

import anna_unit.Assert;
using TypePrinter.MapPrinter;
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
    Assert.stringsAreEqual(Anna.inspect([]), '#A{}');
  }

  public static function shouldPrintDynamic(): Void {
    Assert.stringsAreEqual(Anna.inspect({}), '{  }');
  }

  public static function shouldPrintArrayWithValues(): Void {
    var values: Array<Dynamic> = [348, 349.54, 'foo', 'bar'.atom(), 'Cat'.atom()];
    Assert.stringsAreEqual(Anna.inspect(values), '#A{348, 349.54, "foo", :bar, Cat}');
  }

  public static function shouldPrintEmptyMap(): Void {
    Assert.stringsAreEqual(Anna.inspect(new ObjectMap()), '#M%{}');
  }

  public static function shouldPrintMapWithMixedTypes(): Void {
    var values: Array<Dynamic> = [348, 349.54, 'foo', 'bar'.atom(), 'Cat'.atom()];
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap();
    map.set('foo'.atom(), "bar");
    map.set('bar'.atom(), 234);
    map.set('cat'.atom(), values);
    Assert.stringsAreEqual(Anna.inspect(map), '#M%{:bar => 234, :cat => #A{348, 349.54, "foo", :bar, Cat}, :foo => "bar"}');
  }

  public static function shouldPrintMapWithSameTypes(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap();
    map.set('foo'.atom(), "foo");
    map.set('bar'.atom(), "bar");
    map.set('cat'.atom(), "cat");
    Assert.stringsAreEqual(Anna.inspect(map), '#M%{:bar => "bar", :cat => "cat", :foo => "foo"}');
  }

  public static function shouldPrintMapAsHaxeMap(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap();
    map.set('foo'.atom(), "foo");
    map.set('bar'.atom(), "bar".atom());
    map.set('cat'.atom(), "cat");
    Assert.stringsAreEqual(map.asHaxeString(), '[AtomSupport.atom("bar") => AtomSupport.atom("bar"), AtomSupport.atom("cat") => "cat", AtomSupport.atom("foo") => "foo"]');
  }

  public static function shouldPrintCustomTypes(): Void {
    var sct: SampleCustomType = new SampleCustomType('name'.atom(), 'type'.atom());
    Assert.stringsAreEqual(Anna.toAnnaString(sct), '%Tests.SampleCustomType{:name => :name, :type => :type}');
  }

  public static function shouldPrintDynamicTypeToMap(): Void {
    var dyn: Dynamic = {foo: 'bar'.atom(), baz: 'cat'.atom()};
    Assert.stringsAreEqual(Anna.inspect(dyn), '{ baz: AtomSupport.atom("cat"), foo: AtomSupport.atom("bar") }');
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

class SampleCustomType implements CustomType {
  public var name(default, never): Atom;
  public var type(default, never): Atom;

  public static var nil: SampleCustomType = new SampleCustomType('nil'.atom(), 'nil'.atom());

  public inline function new(name: Atom, type: Atom) {
    Reflect.setField(this, 'name', name);
    Reflect.setField(this, 'type', type);
  }

  public function toAnnaString(): String {
    return CustomTypePrinter.asString(this);
  }

  public function toHaxeString(): String {
    return '';
  }

  public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
    return '';
  }
}