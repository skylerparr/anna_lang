package tests;

import anna_unit.Assert;
@:build(Macros.build())
class TupleTest {

  private static var tuple1: Tuple = @tuple[1, 2, 3];
  public static function shouldCreateATupleVariable(): Void {
    Assert.areEqual(tuple1, Macros.getTuple([1, 2, 3]));
  }

  private static var tuple2: Tuple = @tuple[1, @tuple[2, 4, 6], @tuple[3, 6, 9]];

  public static function shouldCreateATupleWithinATupleVariable(): Void {
    var expect: Array<Dynamic> = [1, Macros.getTuple([2, 4, 6]), Macros.getTuple([3, 6, 9])];
    Assert.areEqual(tuple2, expect);
  }

  private static var tupleArray: Array<Tuple> = {
    tupleArray = [];

    tupleArray.push(@tuple[1, 2, 3]);
    tupleArray.push(@tuple[4, 5, 6]);

    tupleArray;
  }
  public static function shouldCreateTupleWithStaticInitializer(): Void {
    Assert.areEqual(tupleArray, [Macros.getTuple([1,2,3]), Macros.getTuple([4,5,6])]);
  }

  public static function shouldCreateTupleInFunction(): Void {
    var t: Tuple = @tuple[1, 2, 3];
    Assert.areEqual(t, Macros.getTuple([1, 2, 3]));
  }

  public static function shouldCreateTupleWithinTupleInFunction(): Void {
    var t: Tuple = @tuple[1, @tuple[2, 4, 6], @tuple[3, 6, 9]];
    var expect: Array<Dynamic> = [1, Macros.getTuple([2, 4, 6]), Macros.getTuple([3, 6, 9])];
    Assert.areEqual(t, expect);
  }

  public static function shouldCreateTupleWithinAConstructor(): Void {
    var tc: TupleContainer = new TupleContainer(@tuple[1,2,3]);
    Assert.areEqual(tc.args, Macros.getTuple([1,2,3]));
  }

  public static function shouldCreateArrayOfTuplesInAConstructor(): Void {
    var tc: ArrayTupleContainer = new ArrayTupleContainer([@tuple[1,2,3], @tuple[4,5,6]]);
    Assert.areEqual(tc.args, [[1,2,3], [4,5,6]]);
  }

}

class TupleContainer {
  public var args: Tuple;

  public function new(args: Tuple) {
    this.args = args;
  }
}

class ArrayTupleContainer {
  public var args: Array<Tuple>;

  public function new(args: Array<Tuple>) {
    this.args = args;
  }
}