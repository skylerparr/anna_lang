package util;
import haxe.Timer;
class TimeUtil {
  public static function nowInMillis(): Int {
    return Std.int(Timer.stamp() * 1000);
  }

  public static function getHumanTime(microSeconds: Float): String {
    return switch(microSeconds) {
      case val if(microSeconds < 1):
        '${Math.round(microSeconds * 1000)}µs';
      case val if(microSeconds > 1 && microSeconds < 10):
        '${Math.round(microSeconds * 100) / 100}ms';
      case val if(microSeconds >= 10 && microSeconds < 1000):
        '${Math.round(microSeconds)}ms';
      case val if(microSeconds >= 1000 && microSeconds < 10000):
        '${Math.round(microSeconds * 1000000 / 1000000) / 1000}s';
      case val if(microSeconds >= 10000 && microSeconds < 100000):
        '${Math.round(microSeconds * 1000 / 100000) / 10}s';
      case _:
        '${Math.round(microSeconds / 1000)}s';
    }
  }
}
