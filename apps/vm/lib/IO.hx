package ;
class IO {
  public static function print(str: String): Atom {
    cpp.Lib.print(str);
    return Atom.create('ok');
  }

  public static function println(str: String): Atom {
    cpp.Lib.print(str + '\r\n');
    return Atom.create('ok');
  }

  public static function inspect(value: Dynamic, label: String = null): Dynamic {
    Logger.inspect(value, label);
    return value;
  }

  public static function gets(): String {
    var char: Int = Sys.getChar(false);
    return String.fromCharCode(char);
  }

  public static function getsCharCode(): Int {
    return Sys.getChar(false);
  }
}
