package ;

import lang.macros.Macros;
import anna_unit.Assert;
@:build(lang.macros.Macros.build())
class TupleTest {

  private static var tuple1: Tuple = @tuple[1, 2, 3];
  public static function shouldCreateATupleVariable(): Void {
    Assert.areEqual(tuple1.toAnnaString(), '[1, 2, 3]');
  }

  private static var tuple2: Tuple = @tuple[1, @tuple[2, 4, 6], @tuple[3, 6, 9]];
  public static function shouldCreateATupleWithinATupleVariable(): Void {
    Assert.areEqual(tuple2.toAnnaString(), '[1, [2, 4, 6], [3, 6, 9]]');
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
    Assert.areEqual(t.toAnnaString(), "[1, [2, 4, 6], [3, 6, 9]]");
  }

  public static function shouldCreateTupleWithinAConstructor(): Void {
    var tc: TupleContainer = new TupleContainer(@tuple[1,2,3]);
    Assert.areEqual(tc.args, Macros.getTuple([1,2,3]));
  }

  public static function shouldCreateArrayOfTuplesInAConstructor(): Void {
    var tc: ArrayTupleContainer = new ArrayTupleContainer([@tuple[1,2,3], @tuple[4,5,6]]);
    Assert.areEqual(Anna.toAnnaString(tc.args), "#A[[1, 2, 3], [4, 5, 6]]");
  }

  public static function shouldCreateTupleAsFunctionArgs(): Void {
    var tuple: Tuple = @tuple['abc', 1, '2', "mno"];
    tuple = Tuple.push(tuple, @tuple['abc', "def", 'hij', "mno"]);
    Assert.areEqual(tuple.toAnnaString(), '["abc", 1, "2", "mno", ["abc", "def", "hij", "mno"]]');
  }

  public static function shouldCreateAnEmptyTuple(): Void {
    var tuple: Tuple = @tuple[];
    Assert.areEqual(tuple.toAnnaString(), '[]');
  }

  public static function shouldPutNewDataStructureIntoAnEmptyTuple(): Void {
    var tuple: Tuple = @tuple[];
    tuple = Tuple.push(tuple, @list[1,2,3]);
    Assert.areEqual(tuple.toAnnaString(), '[{1, 2, 3}]');
  }

  public static function shouldAddElementAtIndex(): Void {
    var tuple: Tuple = @tuple['ok', 1, 3];
    tuple = Tuple.addElemAt(tuple, '2', 2);
    Assert.areEqual(tuple.toAnnaString(), '["ok", 1, "2", 3]');
  }

  public static function shouldAddElementAtTheEndIfExceedsIndex(): Void {
    var tuple: Tuple = @tuple['ok', 1, 3];
    tuple = Tuple.addElemAt(tuple, '2', 20);
    Assert.areEqual(tuple.toAnnaString(), '["ok", 1, 3, "2"]');
  }

  public static function shouldRemoveElementAtIndex(): Void {
    var tuple: Tuple = @tuple['ok', 1, 3];
    tuple = Tuple.removeElemAt(tuple, 2);
    Assert.areEqual(tuple.toAnnaString(), '["ok", 1]');
  }

  public static function shouldNotRemoveAnyElementIfBeyondIndex(): Void {
    var tuple: Tuple = @tuple['ok', 1];
    tuple = Tuple.removeElemAt(tuple, 2);
    Assert.areEqual(tuple.toAnnaString(), '["ok", 1]');
  }

  public static function shouldCreateTupleWithVariables(): Void {
    var tuple: Tuple = @tuple['ok', message];
    Assert.areEqual(tuple.toAnnaString(), '["ok", [:var, "message"]]');
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