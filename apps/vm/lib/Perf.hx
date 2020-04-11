package ;
import util.TimeUtil;
import haxe.Timer;
class Perf {

  public static function test():Void {
    var iterations = 10000000;

    var t: Tuple = tup();
    var counter: Int = 0;

    var start = Timer.stamp();
    for(i in 0...iterations) {
      if(Std.is(t, Tuple)) {
        counter++;
      }
    }

    var end = Timer.stamp();
    trace('exec time: ${TimeUtil.getHumanTime(end - start)}');

    var counter: Int = 0;
    var foo = {};

    var start = Timer.stamp();
    for(i in 0...iterations) {
      if(cast(t, Tuple) != null) {
        counter++;
      }
    }
    var end = Timer.stamp();

    trace(counter);
    trace('exec time: ${TimeUtil.getHumanTime(end - start)}');
  }

  private static function tup():Dynamic {
    return Tuple.create([]);
  }
}
