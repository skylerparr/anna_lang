package lang.macros;
import lang.macros.AnnaLang;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;

class Def {

  public static function gen(annaLang: AnnaLang, params: Expr): Array<Expr> {
    defineFunction(annaLang, params);
    return [];
  }

  public static function defineFunction(annaLang: AnnaLang, params: Expr):Dynamic {
    var macroContext: MacroContext = annaLang.macroContext;
    var macroTools: MacroTools = annaLang.macroTools;
    var r = ~/[A-Za-z]*<|>/g;
    var funName: String = macroTools.getCallFunName(params);
    var allTypes: Dynamic = macroTools.getArgTypesAndReturnTypes(params, macroContext);
    var funArgsTypes: Array<Dynamic> = allTypes.argTypes;
    var origTypes: Array<String> = [];
    var types: Array<String> = [];
    for(argType in funArgsTypes) {
      if(!argType.isPatternVar) {
        var argTypeStr: String = argType.type;
        macroContext.varTypesInScope.set(argType.name, argTypeStr);
        #if !macro
        argTypeStr = Helpers.getCustomType(argTypeStr, macroContext);
        #end
        var strType: String = macroTools.resolveType(annaLang.macros.haxeToExpr(argTypeStr));
        strType = r.replace(strType, '');
        var origTypeStr: String = '';
        try {
          var funNameArgType = argType.type;
          origTypeStr = Helpers.getType(macroTools.resolveType(annaLang.macros.haxeToExpr(argType.type)), macroContext);
          origTypeStr = r.replace(origTypeStr, '');
          origTypeStr = Helpers.getType(origTypeStr, macroContext);
        } catch(e: Dynamic) {
          origTypeStr = argType.type;
        }
        origTypeStr = Helpers.getAlias(origTypeStr, macroContext);
        origTypes.push(origTypeStr);
        types.push(Helpers.getType(Helpers.getCustomType(strType, macroContext), macroContext));
        argType.type = strType;
      }
    }
    var argTypes: String = Helpers.sanitizeArgTypeNames(types);
    var funBody: Array<Expr> = macroTools.getFunBody(params);

    var internalFunctionName: String = Helpers.makeFqFunName(funName, origTypes);

    // add the functions to the context for reference later
    var funBodies: Array<Dynamic> = macroContext.currentModuleDef.declaredFunctions.get(internalFunctionName);
    if(funBodies == null) {
      funBodies = [];
    }
    var def = {
      name: funName,
      internalFunctionName: internalFunctionName,
      argTypes: argTypes,
      funArgsTypes: funArgsTypes,
      funReturnTypes: allTypes.returnTypes,
      funBody: funBody,
      allTypes: allTypes
    };
    funBodies.push(def);
    macroContext.currentModuleDef.declaredFunctions.set(internalFunctionName, funBodies);
    return def;
  }

}
