package ;
class IO {
  public static function inspect(value: Dynamic, label: String = null): Dynamic {
    Logger.inspect(value, label);
    return value;
  }

  public static function gets(): String {
    var char: Int = Sys.getChar(true);
    return String.fromCharCode(char);
  }

  public static function getsCharCode(): Int {
    return Sys.getChar(true);
  }
}
