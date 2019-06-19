package tests;

import anna_unit.Assert;
using lang.AtomSupport;
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
    Assert.areEqual(Anna.toAnnaString(mapArray), '{%{"abc" => 1, 2 => "mno"}, %{"2" => "mno", "abc" => 1}}');
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
    Assert.areEqual(Anna.toAnnaString(mc.args), '%{"2" => "mno", "abc" => 1}');
  }

  public static function shouldCreateArrayOfMapsInAConstructor(): Void {
    var amc: ArrayMapContainer = new ArrayMapContainer([@map['abc' => 1, '2' => "mno"], @map['abc' => 1, '2' => "mno"]]);
    Assert.areEqual(Anna.toAnnaString(amc.args), '{%{"2" => "mno", "abc" => 1}, %{"2" => "mno", "abc" => 1}}');
  }

  public static function shouldCreateMapAsFunctionArgs(): Void {
    var map: MMap = @map['abc' => 1, '2' => "mno"];
    map = MMap.put(map, 23, @map['abc' => "def", 'hij' => "mno"]);
    Assert.areEqual(map.toAnnaString(), '%{"2" => "mno", "abc" => 1, 23 => %{"abc" => "def", "hij" => "mno"}}');
  }

  public static function shouldCreateAnEmptyMap(): Void {
    var map: MMap = @map[];
    Assert.areEqual(map.toAnnaString(), '%{}');
  }

  public static function shouldPutNewDataStructureIntoAnEmptyMap(): Void {
    var map: MMap = @map[];
    map = MMap.put(map, 23, @list[1,2,3]);
    Assert.areEqual(map.toAnnaString(), '%{23 => [1, 2, 3]}');
  }

  public static function shouldCreateMixedTypesOfDataStructures(): Void {
    var map: MMap = @map["abc" => @list[@tuple["a", "b", "c"], @tuple["d", "e", "f"]],
      "xyz" => @tuple[@map[1 => @list['d', 'e', 'f']], @map[2 => @list['j', 'k', 'l']]]
    ];
    Assert.areEqual(map.toAnnaString(), '%{"abc" => [{"a", "b", "c"}, {"d", "e", "f"}], "xyz" => {%{1 => ["d", "e", "f"]}, %{2 => ["j", "k", "l"]}}}');
  }

  public static function shouldGetAValueFromTheMap(): Void {
    var map: MMap = @map['abc'.atom() => 123];
    Assert.areEqual(MMap.get(map, 'abc'.atom()), 123);
  }

  public static function shouldPutAValueOnTheMap(): Void {
    var map: MMap = @map['abc'.atom() => 123];
    MMap.put(map, 'def'.atom(), 456);
    Assert.areEqual(MMap.get(map, 'abc'.atom()), 123);
    Assert.areEqual(MMap.get(map, 'def'.atom()), 456);
    Assert.areEqual(map.toAnnaString(), '%{:abc => 123, :def => 456}');
  }

  public static function shouldRemoveAValueInTheMap(): Void {
    var map: MMap = @map['abc'.atom() => 123];
    MMap.put(map, 'def'.atom(), 456);
    Assert.areEqual(MMap.get(map, 'abc'.atom()), 123);
    Assert.areEqual(MMap.get(map, 'def'.atom()), 456);
    MMap.remove(map, 'abc'.atom());
    Assert.areEqual(map.toAnnaString(), '%{:def => 456}');
  }
}

class MapContainer {
  public var args: MMap;
  public static var map: MMap;

  public function new(args: MMap) {
    this.args = args;
  }

  public static function setMap(map: MMap): Void {
    MapContainer.map = map;
  }
}

class ArrayMapContainer {
  public var args: Array<MMap>;

  public function new(args: Array<MMap>) {
    this.args = args;
  }
}