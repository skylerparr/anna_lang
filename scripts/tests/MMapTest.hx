package tests;

import haxe.ds.ObjectMap;
import lang.EitherSupport;
import EitherEnums.Either1;
import anna_unit.Assert;
@:build(Macros.build())
class MMapTest {

  private static var __map: MMap = @map['abc' => 1, 2 => "mno"]; // just verifying this'll compile
  private static var map: MMap = @map['abc' => "def", 'hij' => "mno"];
  public static function shouldCreateAStaticMMap(): Void {
    Assert.areEqual(map.toAnnaString(), '%{"abc" => "def", "hij" => "mno"}');
  }

  private static var map2: MMap = @map['abc' => "def", 'hij' => @map['abc' => 1, '2' => "mno"]];
  public static function shouldCreateAMapWithinAMap(): Void {
    Assert.areEqual(map2.toAnnaString(), '%{"abc" => "def", "hij" => %{"2" => "mno", "abc" => 1}}');
  }

  private static var mapArray: Array<MMap> = {
    mapArray = [];

    mapArray.push(@map['abc' => 1, 2 => "mno"]);
    mapArray.push(@map['abc' => 1, '2' => "mno"]);

    mapArray;
  }
  public static function shouldCreateMapWithStaticInitializer(): Void {
    Assert.areEqual(Anna.toAnnaString(mapArray), '{%{2 => "mno", "abc" => 1}, %{"2" => "mno", "abc" => 1}}');
  }

  public static function shouldCreateMapInFunction(): Void {
    var m: MMap = @map['abc' => 1, '2' => "mno"];
    Assert.areEqual(Anna.toAnnaString(m), '%{"2" => "mno", "abc" => 1}');
  }

  public static function shouldCreateMapWithinMapInFunction(): Void {
    var m: MMap = @map[@map['abc' => 1, '2' => "mno"] => @map['abc' => 1, '2' => "mno"]];
    var expect: String = '%{%{"2" => "mno", "abc" => 1} => %{"2" => "mno", "abc" => 1}}';
    Assert.areEqual(m.toAnnaString(), expect);
  }

  public static function shouldCreateMapWithinAConstructor(): Void {
    var mc: MapContainer = new MapContainer(@map['abc' => 1, '2' => "mno"]);
    Assert.areEqual(mc.args, Macros.getMap(['abc' => 1, '2' => "mno"]));
  }

  public static function shouldCreateArrayOfMapsInAConstructor(): Void {
    var amc: ArrayMapContainer = new ArrayMapContainer([@map['abc' => 1, '2' => "mno"], @map['abc' => 1, '2' => "mno"]]);
    Assert.areEqual(Anna.toAnnaString(amc.args), '{%{"2" => "mno", "abc" => 1}, %{"2" => "mno", "abc" => 1}}');
  }

  public static function shouldCreateMixedTypesOfDataStructures(): Void {
    var map: MMap = @map["abc" => @list[@tuple["a", "b", "c"], @tuple["d", "e", "f"]],
      "xyz" => @tuple[@map[1 => @list['d', 'e', 'f']], @map[2 => @list['j', 'k', 'l']]]
    ];
    Assert.areEqual(map.toAnnaString(), '%{"abc" => [{"a", "b", "c"}, {"d", "e", "f"}], "xyz" => {%{1 => ["d", "e", "f"]}, %{2 => ["j", "k", "l"]}}}');
  }
}

class MapContainer {
  public var args: MMap;

  public function new(args: MMap) {
    this.args = args;
  }
}

class ArrayMapContainer {
  public var args: Array<MMap>;

  public function new(args: Array<MMap>) {
    this.args = args;
  }
}