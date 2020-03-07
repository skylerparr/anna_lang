package lang;
import lang.macros.AnnaLang;
import Type.ValueType;
import lang.CustomType;
class UserDefinedType extends AbstractCustomType {
  public var __annaLang: AnnaLang;
  public var __type: String;
  public var __values: Dynamic;

  public function new() {
  }

  public static function create(type: String, arg: Dynamic, annaLang: AnnaLang): AbstractCustomType {
    var retVal: UserDefinedType = Type.createInstance(UserDefinedType, []);
    retVal.__annaLang = annaLang;
    retVal.__type = type;
    retVal.__values = {};

    if(arg == null) {
      return retVal;
    }
    for(field in Reflect.fields(arg)) {
      var valueToAssign = Reflect.field(arg, field);
      Reflect.setField(retVal.__values, field, valueToAssign);
    }
    return retVal;
  }

  override public function toAnnaString(): String {
    var fieldPairs: Array<String> = [];
    for(field in Reflect.fields(__values)) {
      var value = get(this, Atom.create(field));
      fieldPairs.push('${StringTools.replace(Anna.toAnnaString(field), '"', '')}: ${Anna.toAnnaString(value)}');
    }
    return '${__type}%{${fieldPairs.join(', ')}}';
  }

  public function getField(field: String): Dynamic {
    var variablesInScope: Map<String, Dynamic> = null;
    if(vm.Kernel.started) {
      variablesInScope = vm.Process.self().processStack.getVariablesInScope();
    } else {
      variablesInScope = new Map<String, Dynamic>();
    }
    var valueToAssign = Reflect.field(__values, field);
    return ArgHelper.extractArgValue(valueToAssign, variablesInScope, __annaLang);
  }

  public static function get(obj: UserDefinedType, field: Atom): Dynamic {
    return obj.getField(field.value);
  }

  public static function set(obj: UserDefinedType, field: Atom, value: Dynamic): AbstractCustomType {
    var values = obj.__values;
    var arg = {};
    for(valueKey in Reflect.fields(values)) {
      if(field.value == valueKey) {
        Reflect.setField(arg, field.value, value);
      } else {
        Reflect.setField(arg, valueKey, Reflect.field(values, valueKey));
      }
    }
    return create(obj.__type, arg, obj.__annaLang);
  }

  public function clone(): lang.AbstractCustomType {
    return create(__type, __values, __annaLang);
  }
}
