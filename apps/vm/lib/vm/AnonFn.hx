package vm;
import lang.macros.Helpers;
import lang.macros.VarTypesInScope;
import lang.macros.AnnaLang;
class AnonFn implements Function {
  public var args:Array<Dynamic>;
  public var fn:Dynamic;
  public var scope:Map<String, Dynamic>;
  public var apiFunc:Atom;
  public var annaLang: AnnaLang;
  public var module: Atom;
  public var func: String;
  public var instance: Dynamic;

  public function new() {
    args = [];
  }

  public function invoke(args:Array<Dynamic>):Array<Operation> {
    var types: Array<Array<String>> = [];
    var retVal: Array<Operation> = null;
    for(argIndex in 0...(args.length - 1)) {
      var arg = args[argIndex];
      var resolvedTypes = VarTypesInScope.resolveTypes(arg);
      types.push(resolvedTypes);
    }
    for(argTypes in types) {
      argTypes.remove("Dynamic");
      argTypes.push("Dynamic");
    }
    var perms: Array<Array<String>> = [];
    Helpers.generatePermutations(types, perms, 0, []);
    for(typeArgs in perms) {
      var fqFunName: String = Helpers.makeFqFunName(func, typeArgs);
      var fn: Function = Classes.getFunction(module, Atom.create(fqFunName));
      if(fn != null) {
        retVal = Reflect.callMethod(instance, fn.fn, args);
        break;
      }
    }
    return retVal;
  }

}
