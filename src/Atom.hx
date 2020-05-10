package ;
import lang.CustomType;
import lang.HashTableAtoms;
import lang.EmptyAtomException;
@:rtti
class Atom implements CustomType {
  public var variables: Map<String, String>;

  public static inline function create(name: String): Atom {
    return HashTableAtoms.get(name);
  }

  public var value(default, never): String;

  public inline function new(value: String) {
    if(value == "" || value == null) {
      throw new EmptyAtomException("Atom must have a value");
    }
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

  public static function to_s(atom: Atom): String {
    return atom.value;
  }
}
