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

}