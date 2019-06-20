package ;
import lang.CustomTypes.CustomType;
class Atom implements CustomType {
  public static function create(name: String): Atom {
    return new Atom(name);
  }

  public var value(default, never): String;

  public inline function new(value: String) {
//    if(value == "" || value == null) {
//      throw "AnnaLang: Atom must have a value";
//    }
    Reflect.setField(this, 'value', value);
  }

  public function toAnnaString(): String {
    var retVal: String = '';
    switch(value) {
      case 'nil' | 'true' | 'false':
        retVal = value;
      case _:
        var capitals: EReg = ~/[A-Z]/;
        if(!capitals.match(value.charAt(0))) {
          retVal = ':${value}';
        } else {
          retVal = value;
        }
    }
    return retVal;
  }

  public function toHaxeString(): String {
    return 'AtomSupport.atom("${value}")';
  }

  public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
    return '{value: ${value}}';
  }

  public function toString(): String {
    return 'AtomSupport.atom("${value}")';
  }

  public static function to_s(atom: Atom): String {
    return atom.value;
  }
}