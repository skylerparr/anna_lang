package lang;

import Type.ValueType;
import lang.CustomType;
@:rtti
class AbstractCustomType implements CustomType {

  public static function create(type: Class<Dynamic>, args: Dynamic): AbstractCustomType {
    return Type.createInstance(type, [args]);
  }

  public function toAnnaString(): String {
    var fieldPairs: Array<String> = [];
    for(field in Reflect.fields(this)) {
      if(field == "variables") {
        continue;
      }
      fieldPairs.push('${StringTools.replace(Anna.toAnnaString(field), '"', '')}: ${Anna.toAnnaString(Reflect.field(this, field))}');
    }
    var classType: ValueType = Type.typeof(this);
    var name: String = switch(classType) {
      case TClass(name):
        '${name}';
      case _:
        "CustomType";
    }
    return '${name}%{${fieldPairs.join(', ')}}';
  }

  public function clone():AbstractCustomType {
    return this;
  }
}