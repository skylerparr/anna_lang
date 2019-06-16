package tests;

import lang.CustomTypes;
import lang.CustomTypes;
import lang.ModuleSpec;
import anna_unit.Assert;
using lang.AtomSupport;
@:build(Macros.build())
class AnnaListTest {

  public static function shouldPushElement(): Void {
    var list: LList = LList.create([]);
    LList.push(list, 'Foo');
    LList.push(list, 'Bar');
    LList.push(list, 'Cat');
    LList.push(list, 'Baz');
    Assert.areEqual(list.toAnnaString(), '["Baz", "Cat", "Bar", "Foo"]');
  }

  public static function shouldAddElement(): Void {
    var list: LList = LList.create([]);
    LList.add(list, 'Foo');
    LList.add(list, 'Bar');
    LList.add(list, 'Cat');
    LList.add(list, 'Baz');
    Assert.areEqual(list.toAnnaString(), '["Foo", "Bar", "Cat", "Baz"]');
  }

  public static function shouldGetTail(): Void {
    var list: LList = LList.create([]);
    LList.add(list, 'Foo');
    LList.add(list, 'Bar');
    LList.add(list, 'Cat');
    LList.add(list, 'Baz');

    var expect: LList = LList.create([]);
    LList.add(expect, 'Bar');
    LList.add(expect, 'Cat');
    LList.add(expect, 'Baz');

    Assert.areEqual(LList.tl(list), expect);
  }

  public static function shouldGetCorrectTailAfterChange(): Void {
    var list: LList = LList.create([]);
    LList.add(list, 'Foo');
    LList.add(list, 'Bar');
    LList.add(list, 'Cat');

    var expect: LList = LList.create([]);
    LList.add(expect, 'Bar');
    LList.add(expect, 'Cat');
    Assert.areEqual(LList.tl(list), expect);

    LList.add(list, 'Baz');
    LList.add(expect, 'Baz');
    Assert.areEqual(LList.tl(list), expect);

    LList.push(list, 'Kale');
    LList.push(expect, 'Foo');
    Assert.areEqual(LList.tl(list), expect);

    LList.remove(list, 'Bar');
    LList.remove(expect, 'Bar');
    Assert.areEqual(LList.tl(list), expect);
  }

  public static function shouldGetHead(): Void {
    var list: LList = LList.create([]);
    LList.add(list, 'Foo');
    LList.add(list, 'Bar');
    LList.add(list, 'Cat');

    Assert.areEqual(LList.hd(list), 'Foo');
  }

  public static function shouldRemoveElement(): Void {
    var list: LList = LList.create([]);
    var map1: Map<String, String> = new Map<String, String>();
    map1.set('1', '1');
    var map2: Map<String, String> = new Map<String, String>();
    map2.set('2', '2');
    var map3: Map<String, String> = new Map<String, String>();
    map3.set('3', '3');
    LList.add(list, map1);
    LList.add(list, map2);
    LList.add(list, map3);

    var toRemove: Map<String, String> = new Map<String, String>();
    toRemove.set('2', '2');

    Assert.areEqual(LList.remove(list, toRemove), true);

    var toRemove: Map<String, String> = new Map<String, String>();
    toRemove.set('2', '2');

    Assert.areEqual(LList.remove(list, toRemove), false);
  }

  public static function shouldPatternMatchHeadAndTail(): Void {
    var list: LList = LList.create([]);
    LList.add(list, 'Foo');
    LList.add(list, 'Bar');
    LList.add(list, 'Baz');
    LList.add(list, 'Cat');

    switch(list) {
      case({head: head, tail: tail}):
        Assert.areEqual(head, 'Foo');
        var expect = LList.create(['Bar', 'Baz', 'Cat']);
        Assert.areEqual(tail, expect);
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

//  private static var list: LList = @list[1, 2, 3];
//  public static function shouldCreateAList(): Void {
//    Assert.areEqual(list, Macros.getList([1, 2, 3]));
//  }
}

