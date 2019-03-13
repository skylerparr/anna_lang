package tests;

import lang.CustomTypes;
import lang.CustomTypes;
import lang.ModuleSpec;
import anna_unit.Assert;
using lang.AtomSupport;
class AnnaListTest {

  public static function shouldReturnListAndNotAnnaListForToString(): Void {
    Assert.areEqual('List', new AnnaList<String>().toString());
  }

  public static function shouldPushElement(): Void {
    var list: AnnaList<String> = new AnnaList<String>();
    list.push('Foo');
    list.push('Bar');
    Assert.areEqual(list.toAnnaString(), '["Bar", "Foo"]');
  }

  public static function shouldAddElement(): Void {
    var list: AnnaList<String> = new AnnaList<String>();
    list.add('Foo');
    list.add('Bar');
    Assert.areEqual(list.toAnnaString(), '["Foo", "Bar"]');
  }

  public static function shouldRemoveElement(): Void {
    var list: AnnaList<Map<String, String>> = new AnnaList<Map<String, String>>();
    var map1: Map<String, String> = new Map<String, String>();
    map1.set('1', '1');
    var map2: Map<String, String> = new Map<String, String>();
    map2.set('2', '2');
    var map3: Map<String, String> = new Map<String, String>();
    map3.set('3', '3');
    list.add(map1);
    list.add(map2);
    list.add(map3);

    var toRemove: Map<String, String> = new Map<String, String>();
    toRemove.set('2', '2');

    Assert.areEqual(list.remove(toRemove), 1);
    Assert.areEqual(list.toAnnaString(), '[%{"1" => "1"}, %{"3" => "3"}]');

    var toRemove: Map<String, String> = new Map<String, String>();
    toRemove.set('2', '2');

    Assert.areEqual(list.remove(toRemove), 0);
    Assert.areEqual(list.toAnnaString(), '[%{"1" => "1"}, %{"3" => "3"}]');
  }

  public static function shouldPatternMatchHeadAndTail(): Void {
    var list: AnnaList<String> = new AnnaList<String>();
    list.add('Foo');
    list.add('Bar');

    switch(list) {
      case({head: head, tail: tail}):
        Assert.areEqual(head, 'Foo');
        Assert.areEqual(tail, new AnnaList<String>('Bar'));
      case _:
        Assert.areEqual(false, true);
    }

    switch(list) {
      case({head: head}):
        Assert.areEqual(head, 'Foo');
      case _:
        Assert.areEqual(false, true);
    }
  }

  public static function shouldReturnAHaxeStringThatCanInstantiateANewList(): Void {
    var list: AnnaList<String> = new AnnaList<String>();
    list.add('Foo');
    list.add('Bar');

    Assert.areEqual(list.toHaxeString(), 'lang.CustomTypes.createList("String", ["Foo", "Bar"])');

    var list: AnnaList<ModuleSpec> = new AnnaList<ModuleSpec>();
    list.add(ModuleSpec.nil);

    Assert.areEqual(list.toHaxeString(), 'lang.CustomTypes.createList("lang.ModuleSpec", [new ModuleSpec(AtomSupport.atom("nil"), [], AtomSupport.atom("nil"), AtomSupport.atom("nil"))])');
  }

  public static function shouldCreateANewListFromValues(): Void {
    var list: AnnaList<String> = CustomTypes.createList("String", ["Foo", "Bar"]);
    Assert.areEqual(list.toAnnaString(), '["Foo", "Bar"]');

    var moduleSpec = ModuleSpec.nil;
    var list = CustomTypes.createList("ModuleSpec", [moduleSpec]);
    Assert.areEqual(list.toAnnaString(), '[%Lang.ModuleSpec{:module_name => nil, :functions => {}, :class_name => nil, :package_name => nil}]');
  }

  public static function shouldReturnAHaxeMatchString(): Void {
    var list: AnnaList<String> = new AnnaList<String>();
    list.add('Foo');
    list.add('Bar');

    Assert.areEqual(
      list.toPattern([new KeyValue<String, String>('head', 'h'), new KeyValue<String, String>('tail', 't')]),
      '{head: h, tail: t}');

    Assert.areEqual(
      list.toPattern([new KeyValue<String, String>('head', 'h')]),
      '{head: h}');

    Assert.areEqual(
      list.toPattern([new KeyValue<String, String>('tail', 't')]),
      '{tail: t}');
  }

}

