package ;

import TypePrinter.CustomTypePrinter;
import lang.CustomType;
import haxe.Template;
import haxe.ds.ObjectMap;
using lang.AtomSupport;

import anna_unit.Assert;
using TypePrinter.MapPrinter;
class AnnaTest {
  public static function shouldPrintString(): Void {
    Assert.areEqual(Anna.inspect('foo'), '"foo"');
  }

  public static function shouldPrintInt(): Void {
    Assert.areEqual(Anna.inspect(2341), '2341');
  }

  public static function shouldPrintFloat(): Void {
    Assert.areEqual(Anna.inspect(234.1), '234.1');
  }

  public static function shouldPrintNullAsNil(): Void {
    Assert.areEqual(Anna.inspect(null), 'nil');
  }

  public static function shouldPrintTrueAsTrue(): Void {
    Assert.areEqual(Anna.inspect(true), 'true');
  }

  public static function shouldPrintFalseAsFalse(): Void {
    Assert.areEqual(Anna.inspect(false), 'false');
  }

  public static function shouldPrintAtomWithColonAtTheBeginning(): Void {
    Assert.areEqual(Anna.inspect('hello'.atom()), ':hello');
  }

  public static function shouldNotPrintAtomWithColonAtTheBeginningIfStartsWithUppercaseLetter(): Void {
    Assert.areEqual(Anna.inspect('Hello.World'.atom()), 'Hello.World');
  }

  public static function shouldPrintEmptyArray(): Void {
    Assert.areEqual(Anna.inspect([]), '#A[]');
  }

  public static function shouldPrintDynamic(): Void {
    Assert.areEqual(Anna.inspect({}), '{}');
  }

  public static function shouldPrintArrayWithValues(): Void {
    var values: Array<Dynamic> = [348, 349.54, 'foo', 'bar'.atom(), 'Cat'.atom()];
    Assert.areEqual(Anna.inspect(values), '#A[348, 349.54, "foo", :bar, Cat]');
  }

  public static function shouldPrintEmptyMap(): Void {
    Assert.areEqual(Anna.inspect(new ObjectMap()), '#M%{}');
  }

  public static function shouldPrintMapWithMixedTypes(): Void {
    var values: Array<Dynamic> = [348, 349.54, 'foo', 'bar'.atom(), 'Cat'.atom()];
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap();
    map.set('foo'.atom(), "bar");
    map.set('bar'.atom(), 234);
    map.set('cat'.atom(), values);
    Assert.areEqual(Anna.inspect(map), '#M%{:bar => 234, :cat => #A[348, 349.54, "foo", :bar, Cat], :foo => "bar"}');
  }

  public static function shouldPrintMapWithSameTypes(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap();
    map.set('foo'.atom(), "foo");
    map.set('bar'.atom(), "bar");
    map.set('cat'.atom(), "cat");
    Assert.areEqual(Anna.inspect(map), '#M%{:bar => "bar", :cat => "cat", :foo => "foo"}');
  }

  public static function shouldPrintCustomTypes(): Void {
    var sct: SampleCustomType = new SampleCustomType('name'.atom(), 'type'.atom());
    Assert.areEqual(Anna.toAnnaString(sct), '%SampleCustomType{:name => :name, :type => :type}');
  }

  public static function shouldPrintDynamicTypeToMap(): Void {
    var dyn: Dynamic = {foo: 'bar'.atom(), baz: 'cat'.atom()};
    Assert.areEqual(Anna.inspect(dyn), '{baz: :cat, foo: :bar}');
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
}