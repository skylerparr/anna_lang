package tests;

import haxe.ds.ObjectMap;
import lang.EitherSupport;
import EitherEnums.Either1;
import anna_unit.Assert;
@:build(Macros.build())
class MMapTest {

  private static var map: MMap = @map['abc' => "def", 'hij' => "mno"];
  private static var __map: MMap = @map['abc' => 1, 2 => "mno"]; // just verifying this'll compile
  public static function shouldCreateAStaticMMap(): Void {
    Assert.areEqual(Anna.toAnnaString(map), '%{"abc" => "def", "hij" => "mno"}');
  }

//  private static var map2: MMap = @list[1, @list[2, 4, 6], @list[3, 6, 9]];
//  public static function shouldCreateAListWithinAList(): Void {
//    var expect: LList = LList.create([1, Macros.getList([2, 4, 6]), Macros.getList([3, 6, 9])]);
//    Assert.areEqual(list2, expect);
//  }

}