package util;

class StringUtil {

  public static var CAPITALS: EReg = ~/[A-Z]/;
  public static var SYMBOLS: EReg = ~/[!@#$%^&*()_+-=;,.]/;
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
  
  public static inline function toSnakeCase(camelCase: String): String {
    var retVal: String = "";
    var prevChar: String = null;
    for(i in 0...camelCase.length) {
      var char: String = camelCase.charAt(i);
      if(CAPITALS.match(char) && prevChar != null && !SYMBOLS.match(prevChar)) {
        retVal += "_" + char.toLowerCase();
      } else {
        retVal += char.toLowerCase();
      }
      prevChar = char;
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

  public static function substr(string: String, start: Int, length: Int): String {
    return string.substr(start, length);
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

  public static var DECIMAL_POINT: String = ".";
  public static var COMMA: String = ",";

  public static inline function isBlank(value: String): Bool {
    return (value == null || value == "");
  }

  public static inline function addCommas( integer: Float ): String {
    var intString: String = integer + "";
    var intLen: Int = intString.length;
    if ( intLen <= 3 ) {
      return integer + "";
    } else {
      var returnString: String = "";
      var start: Int = 0;
      var end: Int = 3;
      var mod: Int = intLen % 3;

      if ( mod != 0 ) {
        returnString += intString.substring( start, ( start + mod ));
        start += mod;
        end += mod;
      }

      while ( intLen >= end ) {
        if ( start == 0 ) {
          returnString += intString.substring( start, end );
        } else {
          returnString += COMMA + intString.substring( start, end );
        }
        start += 3;
        end += 3;
      }

      return returnString;
    }
  }

  public static inline function fillDigits(integer: Dynamic, maxDigits: Int): String {
    var intString: String = integer + "";
    var intLen: Int = intString.length;
    var diff: Int = maxDigits - intLen;
    for(i in 0...diff) {
      intString = "0" + intString;
    }
    return intString;
  }


  public static inline function addSpaces(string: String, spaceCount: Int = 1): String {
    var numChars: Int = string.length;
    var arr: List<String> = new List<String>();
    for(i in 0...numChars) {
      arr.add(string.charAt(i));
    }
    var spaces: String = "";
    for(i in 0...spaceCount) {
      spaces += " ";
    }
    return arr.join(spaces);
  }

  public static inline function truncate(string: String, maxChars: Int): String {
    if(string.length > maxChars) {
      string = string.substring(0, maxChars) + "...";
    }
    return string;
  }

  public static inline function intToString(i: Null<Int>): String {
    return i + "";
  }
}
