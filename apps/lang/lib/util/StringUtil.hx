package util;

class StringUtil {

  public static var CAPITALS: EReg = ~/[A-Z]/;

  public static function capitalizePackage(string: String): String {
    var retVal: Array<String> = [];

    var frags: Array<String> = string.split('.');
    for(frag in frags) {
      var char: String = frag.charAt(0).toUpperCase();
      retVal.push('${char}${frag.substr(1)}');
    }

    return retVal.join('.');
  }

  public static function random(length:Int = 10):String {
    var chars = "abcdefghijklmnopqrstuvwxyz";
    if (length == 0)
      return "";

    if (length < 0)
      throw "[count] must be positive value";

    if (chars == null)
      throw "[chars] must not be null";

    var result: String = "";
    for (i in 0...length) {
      result += chars.charAt(Math.floor(chars.length * Math.random()));
    }

    return result;
  }

  public static function concat(lhs: String, rhs: String): String {
    return lhs + rhs;
  }

  public static function fromCharCode(charCode: Int): String {
    return String.fromCharCode(charCode);
  }

  public static function substring(string: String, start: Int, end: Int): String {
    return string.substring(start, end);
  }

  public static function length(string: String): Int {
    return string.length;
  }

  public static function rpad(string: String, c: String, l: Int): String {
    return StringTools.rpad(string, c, l);
  }
}