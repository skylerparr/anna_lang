package lang;

import haxe.CallStack;
import lang.AbstractCustomType;
import lang.macros.AnnaLang;
import Type.ValueType;
import lang.CustomType;
@:rtti
class AbstractCustomType implements CustomType {

  public var __annaLang: AnnaLang;
  public var __type: Class<AbstractCustomType>;
  public var __values: Dynamic;

  public static function create(type: Class<AbstractCustomType>, arg: Dynamic, annaLang: AnnaLang): AbstractCustomType {
    var retVal: AbstractCustomType = Type.createInstance(type, []);
    retVal.__annaLang = annaLang;
    retVal.__type = type;
    retVal.__values = {};

    if(arg == null) {
      return retVal;
    }
    var variablesInScope: Map<String, Dynamic> = null;
    if(vm.Process.self() == null) {
      variablesInScope = new Map<String, Dynamic>();
    } else {
      variablesInScope = vm.Process.self().processStack.getVariablesInScope();
    }

    for(field in Reflect.fields(arg)) {
      var valueToAssign = Reflect.field(arg, field);
      var resolvedValue = ArgHelper.extractArgValue(valueToAssign, variablesInScope, annaLang);
      Reflect.setField(retVal.__values, field, resolvedValue);
    }

    return retVal;
  }

  public function toAnnaString(): String {
    var fieldPairs: Array<String> = [];
    for(field in Reflect.fields(__values)) {
      fieldPairs.push('${StringTools.replace(Anna.toAnnaString(field), '"', '')}: ${Anna.toAnnaString(Reflect.field(__values, field))}');
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

  public function getField(field: String): Dynamic {
    return Reflect.field(__values, field);
  }

  public static function set(obj: AbstractCustomType, field: Atom, value: Dynamic): AbstractCustomType {
    var values = obj.__values;
    var arg = {};
    for(valueKey in Reflect.fields(values)) {
      if(field.value == valueKey) {
        Reflect.setField(arg, field.value, value);
      } else {
        Reflect.setField(arg, valueKey, Reflect.field(obj, valueKey));
      }
    }
    return create(obj.__type, arg, obj.__annaLang);
  }

  public function clone(): lang.AbstractCustomType {
    return create(__type, __values, __annaLang);
  }
}