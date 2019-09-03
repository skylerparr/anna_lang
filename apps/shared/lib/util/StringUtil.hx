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
}