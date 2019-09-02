package tests;
import haxe.Timer;
import util.TimeUtil;
@:build(lang.macros.Macros.build())
class TimeUtilTest {
  public static function shouldConvertTimeToMicroSecondsWhenUnder1Millisecond(): Void {
    @assert TimeUtil.getHumanTime(0.02288818359375) == '23µs';
    @assert TimeUtil.getHumanTime(0.12288818359375) == '123µs';
  }

  public static function shouldPrintFractionsOfAMillisecondWhenLessThan10(): Void {
    @assert TimeUtil.getHumanTime(3.02288818359375) == '3.02ms';
  }

  public static function shouldPrintMillisecondsWhenLessThan1000(): Void {
    @assert TimeUtil.getHumanTime(30.2288818359375) == '30ms';
    @assert TimeUtil.getHumanTime(230.2288818359375) == '230ms';
  }

  public static function shouldPrintFractionsOfASecondWhenLessThan10000(): Void {
    @assert TimeUtil.getHumanTime(6230.2288818359375) == '6.23s';
  }

  public static function shouldNotPrintFractionsOfASecondWhenGreaterThan1000000(): Void {
    @assert TimeUtil.getHumanTime(16230.2288818359375) == '16.2s';
    @assert TimeUtil.getHumanTime(316230.2288818359375) == '316s';
  }

}
