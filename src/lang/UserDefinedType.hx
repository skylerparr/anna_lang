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
    var retVal: UserDefinedType = Type.createInstance(UserDefinedType, []);
    retVal.__annaLang = annaLang;
    retVal.__type = type;
    retVal.__values = arg;

    if(arg == null) {
      return retVal;
    }
    return retVal;
  }

  public static function fields(type:UserDefinedType):Array<Atom> {
    var retVal: Array<Atom> = [];
    for(key in type.__values.keys()) {
      retVal.push(key);
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
    var values = obj.__values;
    var arg: Map<Atom, Dynamic> = new Map<Atom, Dynamic>();
    for(valueKey in values.keys()) {
      if(field == valueKey) {
        arg.set(valueKey, value);
      } else {
        arg.set(valueKey, values.get(valueKey));
      }
    }
    var retVal = create(obj.__type, arg, obj.__annaLang);
    return retVal;
  }

  public inline function clone(): lang.AbstractCustomType {
    return create(__type, __values, __annaLang);
  }
}
