package lang;
import haxe.CallStack;
import lang.macros.AnnaLang;
class UserDefinedType extends AbstractCustomType {
  public var __annaLang: AnnaLang;
  public var __type: String;
  public var __values: Map<Atom, Dynamic>;

  public function new() {
  }

  public static function create(type: String, arg: Map<Atom, Dynamic>, annaLang: AnnaLang): AbstractCustomType {
    var retVal: UserDefinedType = new UserDefinedType();
    retVal.__annaLang = annaLang;
    retVal.__type = type;
    retVal.__values = arg;
    return retVal;
  }

  public static function fields(type:UserDefinedType): LList {
    var retVal: Array<Any> = [];
    for(key in type.__values.keys()) {
      retVal.push(key);
    }
    return LList.create(retVal);
  }

  public static function rawFields(type: UserDefinedType): Array<Atom> {
    var retVal: Array<Atom> = [];
    for(key in type.__values.keys()) {
      retVal.push(key);
    }
    return retVal;
  }

  override public function toAnnaString(): String {
    var fieldPairs: Array<String> = [];
    for(field in __values.keys()) {
      var value = get(this, field);
      fieldPairs.push('${field.value}: ${Anna.toAnnaString(value)}');
    }
    return '${__type}%{${fieldPairs.join(', ')}}';
  }

  public function getField(field: Atom): Dynamic {
    var variablesInScope: Map<String, Dynamic> = null;
    if(vm.NativeKernel.started) {
      variablesInScope = vm.Process.self().processStack.getVariablesInScope();
    } else {
      variablesInScope = new Map<String, Dynamic>();
    }
    var valueToAssign = __values.get(field);
    return ArgHelper.extractArgValue(valueToAssign, variablesInScope, __annaLang);
  }

  public static function get(obj: UserDefinedType, field: Atom): Dynamic {
    return obj.getField(field);
  }

  public static function set(obj: UserDefinedType, field: Atom, value: Dynamic): AbstractCustomType {
    var values: Map<Atom, Dynamic> = obj.__values;
    var retVal: Map<Atom, Dynamic> = new Map<Atom, Dynamic>();
    for(key in values.keys()) {
      if(key == field) {
        retVal.set(key, value);
      } else {
        retVal.set(key, values.get(key));
      }
    }
    return create(obj.__type, retVal, obj.__annaLang);
  }

  public inline function clone(): lang.AbstractCustomType {
    return create(__type, __values, __annaLang);
  }
}
