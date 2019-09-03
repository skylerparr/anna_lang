package lang.macros;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;

class Def {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  #if macro
  public static function gen(params: Expr): Array<Expr> {
    defineFunction(params);
    return [];
  }

  public static function defineFunction(params: Expr):Dynamic {
    var funName: String = MacroTools.getCallFunName(params);
    var allTypes: Dynamic = MacroTools.getArgTypesAndReturnTypes(params);
    var funArgsTypes: Array<Dynamic> = allTypes.argTypes;
    var types: Array<String> = [];
    for(argType in funArgsTypes) {
      var strType: String = MacroTools.resolveType(lang.macros.Macros.haxeToExpr(argType.type));
      var r = ~/[A-Za-z]*<|>/g;
      strType = r.replace(strType, '');
      types.push(AnnaLang.getType(strType));
      argType.type = strType;
    }
    var argTypes: String = StringTools.replace(types.join('_'), ".", "_");
    var funBody: Array<Expr> = MacroTools.getFunBody(params);

    var internalFunctionName: String = '${funName}_${argTypes}';

    // add the functions to the context for reference later
    var funBodies: Array<Dynamic> = MacroContext.declaredFunctions.get(internalFunctionName);
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
    MacroContext.declaredFunctions.set(internalFunctionName, funBodies);
    return def;
  }

  #end

}