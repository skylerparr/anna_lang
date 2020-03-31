package lang.macros.opgen;
import haxe.macro.Printer;
import haxe.macro.Expr;
class CreatePushStack {
  public static function gen(currentModuleStr: String, funName: String, args: Array<Expr>, lineNumber: Int, annaLang: AnnaLang):Array<Expr> {
    var printer: Printer = annaLang.printer;
    var macroContext: MacroContext = annaLang.macroContext;
    var macroTools: MacroTools = annaLang.macroTools;
    var macros: Macros = annaLang.macros;

    var moduleName: String = currentModuleStr;
    if(moduleName == "") {
      var moduleDef: ModuleDef = macroContext.currentModuleDef;
      moduleName = moduleDef.moduleName;
    }
    var module: ModuleDef = macroContext.declaredClasses.get(moduleName);
    if(module == null) {
      module = macroContext.declaredInterfaces.get(moduleName);
    }
    moduleName = module.moduleName;

    var fqFunNameTypeMap: Map<String, String> = new Map();
    var types: Array<Array<String>> = [];
    var funArgs: Array<String> = [];
    var argCounter: Int = 0;
    var retVal: Array<Expr> = [];
    var argStrings: Array<String> = [];

    for(arg in args) {
      argStrings.push(printer.printExpr(arg));

      switch(arg.expr) {
        case ECall(_, _):
          var argString = '__${funName}_${argCounter} = ${printer.printExpr(arg)};';
          #if !macro
          vm.Process.self().processStack.getVariablesInScope().set('__${funName}_${argCounter}', 'Unknown');
          #end
          arg = macros.haxeToExpr(argString);
          var exprs: Array<Expr> = annaLang.walkBlock(macroTools.buildBlock([arg]));
          for(expr in exprs) {
            retVal.push(expr);
          }
          types.push([Helpers.getType(StringTools.replace(macroContext.lastFunctionReturnType, '.', '_'), macroContext)]);
          funArgs.push(macroTools.getTuple([macroTools.getAtom("var"), '"__${funName}_${argCounter}"']));
        case EField({expr: EConst(CIdent(obj))}, fieldName):
          var typeAndValue = macroTools.getTypeAndValue(arg, macroContext);
          var type: String = macroContext.varTypesInScope.getTypes(obj)[0];
          type = macroContext.getFieldType(type, fieldName);
          type = Helpers.getType(type, macroContext);
          types.push([type]);
          funArgs.push(typeAndValue.value);
        case _:
          var typeAndValue = macroTools.getTypeAndValue(arg, macroContext);
          var typesForVar: Array<String> = getTypesForVar(typeAndValue, arg, macroContext);
          var possibleTypes: Array<String> = [];
          for(typeForVar in typesForVar) {
            var type: String = Helpers.getType(typeForVar, macroContext);
            type = StringTools.replace(type, '.', '_');
            type = Helpers.getAlias(type, macroContext);
            possibleTypes.remove(type);
            possibleTypes.push(type);
          }
          types.push(possibleTypes);
          funArgs.push(typeAndValue.value);
      }
    }

    var perms: Array<Array<String>> = [];
    generatePermutations(types, perms, 0, []);
    var possibleSignatures: Array<String> = [];

    for(typeArgs in perms) {
      var fqFunName: String = Helpers.makeFqFunName(funName, typeArgs);
      var frags: Array<String> = fqFunName.split('.');
      fqFunName = frags.pop();
      var declaredFunctions: Map<String, Array<Dynamic>> = new Map<String, Array<Dynamic>>();
      if(module != null) {
        declaredFunctions = module.declaredFunctions;
      }
      if(declaredFunctions == null) {
        throw new FunctionClauseNotFound("AnnaLang: No function found");
      }

      var funDef: Dynamic = declaredFunctions.get(fqFunName);
      if(funDef == null) {
        var types: Array<String> = macroContext.varTypesInScope.getTypes(funName);
        if(types == null) {
          continue;
        }
        var varTypeInScope: String = types[0];
        if(varTypeInScope == 'vm_Function' || varTypeInScope == 'vm.Function') {
          var haxeStr: String = 'ops.push(new vm.AnonymousFunction(${macroTools.getAtom(funName)}, ${macroTools.getList(funArgs)}, ${macroTools.getAtom(currentModuleStr)}, ${macroTools.getAtom(macroContext.currentFunction)}, ${lineNumber}, Code.annaLang))';
          retVal.push(macros.haxeToExpr(haxeStr));
          return retVal;
        }
      } else {
        #if macro
        macroContext.lastFunctionReturnType = funDef[0].funReturnTypes[0];
        #else
        var returnTypes: String = funDef[0].funReturnTypes;
        macroContext.lastFunctionReturnType = returnTypes.substr(1, returnTypes.length - 2);
        #end
        var expr = buildPushStackExpr(moduleName, fqFunName, funArgs, currentModuleStr, macroContext.currentFunction, lineNumber, macroTools);
        retVal.push(expr);
        return retVal;
      }
    }
    var types: Array<String> = macroContext.varTypesInScope.getTypes(funName);
    if(types == null) {
      throw new FunctionClauseNotFound('AnnaLang: No function found for ${moduleName}.${funName}(${argStrings.join(', ')})');
    }
    #if !macro
    var fun = vm.Process.self().processStack.getVariablesInScope().get(funName);
    if(Std.is(fun, vm.Function)) {
      var haxeStr: String = 'ops.push(new vm.AnonymousFunction(${macroTools.getAtom(funName)}, ${macroTools.getList(funArgs)}, ${macroTools.getAtom(currentModuleStr)}, ${macroTools.getAtom(macroContext.currentFunction)}, ${lineNumber}, Code.annaLang))';
      retVal.push(macros.haxeToExpr(haxeStr));
      return retVal;
    }
    var typesInScope = macroContext.varTypesInScope.getTypes(funName);
    for(type in typesInScope) {
      if(Helpers.getAlias(type, macroContext) == "vm.Function") {
        var haxeStr: String = 'ops.push(new vm.AnonymousFunction(${macroTools.getAtom(funName)}, ${macroTools.getList(funArgs)}, ${macroTools.getAtom(currentModuleStr)}, ${macroTools.getAtom(macroContext.currentFunction)}, ${lineNumber}, Code.annaLang))';
        retVal.push(macros.haxeToExpr(haxeStr));
        return retVal;
      }
    }
    #end
    throw new FunctionClauseNotFound('AnnaLang: Function ${moduleName}.${funName} with args [${argStrings.join(', ')}] types: [${types.join(', ')}] at line ${lineNumber} not found');
  }

  private static inline function generatePermutations(lists:Array<Array<String>>, result: Array<Array<String>>, depth: Int, current: Array<String>):Void {
    var solutions: Int = 1;
    for(i in 0...lists.length) {
      solutions *= lists[i].length;
    }
    for(i in 0...solutions) {
      var j: Int = 1;
      var items: Array<String> = [];
      for(item in lists) {
        items.push(item[Std.int(i/j) % item.length]);
        j *= item.length;
      }
      result.push(items);
    }
  }

  private static inline function getTypesForVar(typeAndValue: Dynamic, arg: Expr, macroContext: MacroContext):Array<String> {
    return switch(arg.expr) {
      case EConst(CIdent(varName)):
        if(typeAndValue.rawValue == "vm_Function") {
          return ["vm_Function"];
        }
        if(macroContext.currentModuleDef.constants.get(varName) == null) {
          macroContext.varTypesInScope.getTypes(varName);
        } else {
          [typeAndValue.type];
        }
      case _:
        [typeAndValue.type];
    }
  }

  private static inline function buildPushStackExpr(moduleName: String, fqFunName:
        String, funArgs:Array<String>, currentModuleStr: String,
        currentFunction, lineNumber: Int, macroTools: MacroTools): Expr {
    var annaLangArg: Expr = macro Code.annaLang;

    return macro ops.push(new vm.PushStack($e{macroTools.getAtomExpr(moduleName)},
          $e{macroTools.getAtomExpr(fqFunName)},
          $e{macroTools.getListExpr(funArgs)},
          $e{macroTools.getAtomExpr(currentModuleStr)},
          $e{macroTools.getAtomExpr(currentFunction)},
          $e{macroTools.buildConst(CInt(lineNumber + ''))},
          $e{annaLangArg}));
  }
}
