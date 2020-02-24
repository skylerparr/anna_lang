package lang.macros;

import lang.macros.AnnaLang;
import lang.macros.MacroTools;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;

class Fn {
  public static function gen(annaLang: AnnaLang, params: Expr): Array<Expr> {
    var macroContext: MacroContext = annaLang.macroContext;
    var macros: Macros = annaLang.macros;
    var macroTools: MacroTools = annaLang.macroTools;

    var currentModule: TypeDefinition = macroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    #if !macro
    var patternTest = '';
    var index: Int = 0;
    var funArgs: Array<FunctionArg> = null;
    var operationGroups: Array<Array<vm.Operation>> = [];
    var paramNameStrings: Array<String> = [];
    #end
    switch(params.expr) {
      case EBlock(exprs):
        var anonFunctionName: String = "_" + haxe.crypto.Sha256.encode('${Math.random()}');
        var defined = null;
        for(expr in exprs) {
          var typesAndBody: Array<Dynamic> = switch(expr.expr) {
            case EBinop(OpArrow, types, body):
              var typesStr: String = annaLang.printer.printExpr(types);
              [typesStr.substr(1, typesStr.length - 2), body];
            case e:
              MacroLogger.log(e, 'e');
              MacroLogger.logExpr(params, 'params');
              throw new ParsingException("AnnaLang: Expected parenthesis");
          }
          var haxeStr: String = '${anonFunctionName}(${typesAndBody[0]}, ${annaLang.printer.printExpr(typesAndBody[1])});';
          var expr = annaLang.macros.haxeToExpr(haxeStr);
          defined = Def.defineFunction(annaLang, expr);
          defined.varTypesInScope = macroContext.varTypesInScope;
          #if !macro
          var paramsStr: String = typesAndBody[0];
          paramsStr = paramsStr.substr(1, paramsStr.length - 2);
          var paramsStrs = paramsStr.split(',');
          for(pStr in paramsStrs) {
            var typeAndName = pStr.split(':');
            var typeString: String = StringTools.trim(Helpers.getType(typeAndName[0], macroContext));
            if(typeString.length > 0) {
              var paramName: String = StringTools.trim(typeAndName[1]);
              paramNameStrings.push(paramName);
              macroContext.varTypesInScope.set(paramName, typeString);
            }
          }

          var funHeads: Dynamic = annaLang.buildFunctionHeadPatternMatch(defined);
          var patternMatches: Array<String> = funHeads.patternMatches;
          funArgs = funHeads.funArgs;
          var matchCount: Int = funHeads.matchCount;
          patternTest += annaLang.makeFunctionHeadPatternReturn(patternMatches, funArgs, 'return allOps${index++};');
          var terms: Array<Dynamic> = cast(defined.funBody, Array<Dynamic>);
          var allOps: Array<vm.Operation> = [];
          for(term in terms) {
            var operations: Array<vm.Operation> = annaLang.lang.resolveOperations(cast term);
            allOps = allOps.concat(operations);
          }
          operationGroups.push(allOps);
          #end
        }
        #if !macro
        patternTest += 'return null;';

        var paramArgs: Array<String> = [];
        for(funArg in funArgs) {
          paramArgs.push(funArg.name);
        }
        var anonFnString = 'function(${paramArgs.join(', ')}) {
          ${patternTest}
        }';
        var ast = annaLang.parser.parseString(anonFnString);
        var interp = vm.Lang.getHaxeInterp();
        for(i in 0...operationGroups.length) {
          interp.variables.set('allOps${i}', operationGroups[i]);
        }
        var anonFn = new vm.SimpleFunction();
        anonFn.fn = interp.execute(ast);
        anonFn.args = paramNameStrings;
        anonFn.scope = vm.Process.self().processStack.getVariablesInScope();
        anonFn.apiFunc = Atom.create(macroContext.currentFunction);
        vm.Classes.defineFunction(Atom.create(currentModuleStr), Atom.create(defined.internalFunctionName), anonFn);
        #end
        macroContext.lastFunctionReturnType = "vm_Function";
        return [buildDeclareAnonFunctionExpr(annaLang, currentModuleStr, defined.internalFunctionName, params)];
      case _:
        MacroLogger.log(params, 'params');
        MacroLogger.logExpr(params, 'params');
        throw new ParsingException("AnnaLang: Expected block");
    }
  }

  public static function buildDeclareAnonFunctionExpr(annaLang: AnnaLang,
                                                      currentModuleStr: String,
                                                      internalFunctionName: String,
                                                      params): Expr {
    var macroContext = annaLang.macroContext;
    var macroTools = annaLang.macroTools;
    var annaLangArg: Expr = macro Code.annaLang;

    return macro ops.push(new vm.DeclareAnonFunction(
      $e{macroTools.getAtomExpr('${currentModuleStr}.${internalFunctionName}')},
      $e{macroTools.getAtomExpr(currentModuleStr)},
      $e{macroTools.getAtomExpr(macroContext.currentFunction)},
      $e{macroTools.buildConst(CInt(macroTools.getLineNumber(params) + ''))},
      $e{annaLangArg}));
  }
}
