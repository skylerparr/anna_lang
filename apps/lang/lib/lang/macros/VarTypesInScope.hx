package lang.macros;
import haxe.CallStack;
import haxe.rtti.CType.Classdef;
class VarTypesInScope {
  public var varTypesInScope: Map<String, Array<String>>;

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

    var dictionary: Map<String, Dynamic> = MMap.haxeMap(vm.Process.self().dictionary);
    var varsInScope: Map<String, Dynamic> = vm.Process.self().processStack.getVariablesInScope();
    for(key in dictionary.keys()) {
      var varKey = StringTools.replace(key, '"', '');
      varsInScope.set(varKey, dictionary.get(key));
    }

    var value: Dynamic = varsInScope.get(name);
    var varType: String = '';
    var cls: Class<Dynamic> = Type.getClass(value);
    if(cls == null) {
      var types = varTypesInScope.get(name);
      if(types == null) {
        return null;
      }
      for(type in types) {
        retVal.push(type);
      }
    } else if(haxe.rtti.Rtti.hasRtti(cls)) {
      var clsDef: Classdef = haxe.rtti.Rtti.getRtti(cls);
      for(iface in clsDef.interfaces) {
        retVal.push(iface.path);
      }
      if(clsDef.superClass != null) {
        retVal.push(clsDef.superClass.path);
      }
    } else {
      var cls: Class<Dynamic> = Type.getClass(value);
      varType = '${cls}';
      retVal.push(varType);
    }
    return retVal;
  }

  public function resolveClass(name: String): Class<Dynamic> {
    return Type.resolveClass(name);
  }

  public function resolveReturnType(clazz: Class<Dynamic>, funName: String): String {
    if(haxe.rtti.Rtti.hasRtti(clazz)) {
      var clsDef: Classdef = haxe.rtti.Rtti.getRtti(clazz);
      for(field in clsDef.statics) {
        if(field.name == funName) {
          switch(field.type) {
            case CFunction(_, CClass(type, _)):
              return type;
            case _:
              return 'Dynamic';
          }
        }
      }
    }
    return 'Dynamic';
  }
  #end

  public function set(name: String, value: String): Void {
    var types: Array<String> = getVarsInScopeInstance(name);
    types.remove(value);
    types.push(value);
    varTypesInScope.set(name, types);
  }

  public function join(scope: VarTypesInScope): VarTypesInScope {
    for(key in scope.varTypesInScope.keys()) {
      var types: Array<String> = scope.getTypes(key);
      for(type in types) {
        set(key, type);
      }
    }
    return this;
  }

  public function clone(): VarTypesInScope {
    var retVal = new VarTypesInScope();
    for(key in varTypesInScope.keys()) {
      var types: Array<String> = retVal.getTypes(key);
      types.concat(varTypesInScope.get(key));
      for(type in types) {
        retVal.set(key, type);
      }
    }
    return retVal;
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
