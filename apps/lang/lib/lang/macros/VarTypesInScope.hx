package lang.macros;
import haxe.CallStack;
import haxe.rtti.CType.Classdef;
class VarTypesInScope {
  private var varTypesInScope: Map<String, Array<String>>;

  public function new() {
    varTypesInScope = new Map();
  }

  #if macro
  public function getTypes(name: String): Array<String> {
    return getVarsInScopeInstance(name);
  }
  #else
  public function getTypes(name: String): Array<String> {
    var retVal: Array<String> = [];
    var varsInScope: Map<String, Dynamic> = vm.Process.self().processStack.getVariablesInScope();

    var value: Dynamic = varsInScope.get(name);
    var varType: String = '';
    var cls: Class<Dynamic> = Type.getClass(value);
    if(cls == null) {
      var types = varTypesInScope.get(name);
      for(type in types) {
        retVal.push(type);
      }
    } else if(haxe.rtti.Rtti.hasRtti(cls)) {
      var clsDef: Classdef = haxe.rtti.Rtti.getRtti(cls);
      for(iface in clsDef.interfaces) {
        retVal.push(iface.path);
      }
      retVal.push(clsDef.superClass.path);
    } else {
      var cls: Class<Dynamic> = Type.getClass(value);
      varType = '${cls}';
      retVal.push(varType);
    }

    return retVal;
  }
  #end

  public function set(name: String, value: String): Void {
    var types: Array<String> = getVarsInScopeInstance(name);
    types.push(value);
    varTypesInScope.set(name, types);
  }

  private inline function getVarsInScopeInstance(name: String): Array<String> {
    var retVal: Array<String> = varTypesInScope.get(name);
    if(retVal == null) {
      retVal = [];
    }
    return retVal;
  }

  public function toString(): String {
    return Anna.inspect(varTypesInScope);
  }
}
