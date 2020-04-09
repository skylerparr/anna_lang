package util;

class StringUtil {

  public static var CAPITALS: EReg = ~/[A-Z]/;
  private static inline var CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

  public static inline function capitalizePackage(string: String): String {
    var retVal: Array<String> = [];

    var frags: Array<String> = string.split('.');
    for(frag in frags) {
      var char: String = frag.charAt(0).toUpperCase();
      retVal.push('${char}${frag.substr(1)}');
    }

    return retVal.join('.');
  }

  public static inline function nameify(snake_name: String): String {
    var retVal: String = "";
    var capitalizeNext: Bool = true;
    for(i in 0...snake_name.length) {
      var char: String = snake_name.charAt(i);
      if(capitalizeNext) {
        retVal += char.toUpperCase();
        capitalizeNext = false;
      } else if(char == '_') {
        capitalizeNext = true;
      } else {
        retVal += char;
      }
    }
    return retVal;
  }

  public static function random(length:Int = 10):String {
    if (length == 0) {
      return "";
    }

    if (length < 0) {
      throw "[count] must be positive value";
    }

    if (CHARS == null) {
      throw "[chars] must not be null";
    }

    var result: String = "";
    for (i in 0...length) {
      result += CHARS.charAt(Math.floor(CHARS.length * Math.random()));
    }

    return result;
  }

  public static inline function concat(lhs: String, rhs: String): String {
    return lhs + rhs;
  }

  public static function fromCharCode(charCode: Int): String {
    return String.fromCharCode(charCode);
  }

  public static function substring(string: String, start: Int, end: Int): String {
    return string.substring(start, end);
  }

  public static inline function length(string: String): Int {
    return string.length;
  }

  public static function rpad(string: String, c: String, l: Int): String {
    return StringTools.rpad(string, c, l);
  }

  public static inline function split(string: String, delimiter: String): LList {
    var array: Array<String> = string.split(delimiter);
    return LList.create(cast array);
  }

  public static inline function endsWith(string:String, starts: String):Atom {
    var result: Bool = StringTools.endsWith(string, starts);
    if(result) {
      return Atom.create('true');
    } else {
      return Atom.create('false');
    }
  }

  private static var stripWhiteSpaceRegex: EReg = ~/$\s*/;

  public static function removeWhitespace(string: String):String {
    return stripWhiteSpaceRegex.replace(string, "");
  } 
}