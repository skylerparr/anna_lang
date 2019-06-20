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
    var map1: MMap = @map['1' => '1'];
    var map2: MMap = @map['2' => '2'];
    var map3: MMap = @map['3' => '3'];
    LList.add(list, map1);
    LList.add(list, map2);
    LList.add(list, map3);

    var toRemove: MMap = @map['2' => '2'];

    Assert.areEqual(LList.remove(list, toRemove).toAnnaString(), '[%{"1" => "1"}, %{"3" => "3"}]');

    toRemove = @map['2' => '2'];

    Assert.areEqual(LList.remove(list, toRemove).toAnnaString(), '[%{"1" => "1"}, %{"3" => "3"}]');
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

  private static var _list: LList = @list[1, '2', 3]; // just verifying this'll compile
  private static var list: LList = @list[1, 2, 3];
  public static function shouldCreateAList(): Void {
    Assert.areEqual(list, Macros.getList([1, 2, 3]));
  }

  private static var list2: LList = @list[1, @list[2, 4, 6], @list[3, 6, 9]];
  public static function shouldCreateAListWithinAList(): Void {
    var expect: LList = LList.create([1, Macros.getList([2, 4, 6]), Macros.getList([3, 6, 9])]);
    Assert.areEqual(list2, expect);
  }

  private static var listArray: Array<LList> = {
    listArray = [];

    listArray.push(@list[1, 2, 3]);
    listArray.push(@list[4, 5, 6]);

    listArray;
  }
  public static function shouldCreateListWithStaticInitializer(): Void {
    Assert.areEqual(listArray, [Macros.getList([1,2,3]), Macros.getList([4,5,6])]);
  }

  public static function shouldCreateListInFunction(): Void {
    var t: LList = @list[1, 2, 3];
    Assert.areEqual(t, Macros.getList([1, 2, 3]));
  }

  public static function shouldCreateListWithinListInFunction(): Void {
    var t: LList = @list[1, @list[2, 4, 6], @list[3, 6, 9]];
    var expect: LList = LList.create([1, Macros.getList([2, 4, 6]), Macros.getList([3, 6, 9])]);
    Assert.areEqual(t, expect);
  }

  public static function shouldCreateListWithinAConstructor(): Void {
    var tc: ListContainer = new ListContainer(@list[1,2,3]);
    Assert.areEqual(tc.args, Macros.getList([1,2,3]));
  }

  public static function shouldCreateArrayOfListsInAConstructor(): Void {
    var tc: ArrayListContainer = new ArrayListContainer([@list[1,2,3], @list[4,5,6]]);
    Assert.areEqual(tc.args, [Macros.getList([1,2,3]), Macros.getList([4,5,6])]);
  }

  public static function shouldCreateListAsFunctionArgs(): Void {
    var list: LList = @list['abc', 1, '2', "mno"];
    list = LList.push(list, @list['abc', "def", 'hij', "mno"]);
    Assert.areEqual(list.toAnnaString(), '[["abc", "def", "hij", "mno"], "abc", 1, "2", "mno"]');
  }

  public static function shouldCreateAnEmptyList(): Void {
    var list: LList = @list[];
    Assert.areEqual(list.toAnnaString(), '[]');
  }

  public static function shouldPutNewDataStructureIntoAnEmptyList(): Void {
    var list: LList = @list[];
    list = LList.add(list, @list[1,2,3]);
    Assert.areEqual(list.toAnnaString(), '[[1, 2, 3]]');
  }

}


class ListContainer {
  public var args: LList;

  public function new(args: LList) {
    this.args = args;
  }
}

class ArrayListContainer {
  public var args: Array<LList>;

  public function new(args: Array<LList>) {
    this.args = args;
  }
}