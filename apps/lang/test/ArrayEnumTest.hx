package ;

using lang.AtomSupport;

import anna_unit.Assert;
class ArrayEnumTest {

  public static function shouldJoinCollectionWithString(): Void {
    var coll: Array<String> = ["a", "b", "c"];
    Assert.areEqual(ArrayEnum.join(coll, "|"), "a|b|c");
  }

  public static function shouldAddIndexToArray(): Void {
    var coll: Array<String> = ["a", "b", "c"];
    Assert.areEqual(ArrayEnum.with_index(coll), [["a", 0], ["b", 1], ["c", 2]]);
  }

  public static function shouldInsertIntoADifferentCollection(): Void {
    var coll: Array<String> = ["a", "b", "c"];
    Assert.areEqual(ArrayEnum.into(coll, [], function(val: String): String {
      return val + "x";
    }), ["ax", "bx", "cx"]);
  }

  public static function shouldReduceArray(): Void {
    var coll: Array<String> = ["a", "b", "c"];
    Assert.areEqual(ArrayEnum.reduce(coll, [], function(val: String, acc: Array<String>): Array<String> {
      return {
        if(val == "b") {
          acc;
        } else {
          acc.push(val);
        }
        acc;
      };
    }), ["a", "c"]);
  }

}