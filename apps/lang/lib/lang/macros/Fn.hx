package lang.macros;

import lang.macros.AnnaLang;
import lang.macros.MacroTools;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;

class Fn {
  public static function gen(annaLang: AnnaLang, params: Expr): Array<Expr> {
    var macroContext: MacroContext = annaLang.macroContext;

    macroContext.lastFunctionReturnType = "vm_Function";
    var currentModule: TypeDefinition = macroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    #if !macro
    var paramTypeStrings: Array<String> = [];
    var paramNameStrings: Array<String> = [];
    #end
    switch(params.expr) {
      case EBlock(exprs):
        var counter: Int = 0;
        var anonFunctionName: String = "_" + haxe.crypto.Sha256.encode('${Math.random()}');
        var defined = null;
        for(expr in exprs) {
          var typesAndBody: Array<Dynamic> = switch(expr.expr) {
            case EParenthesis({expr: EBinop(OpArrow, types, body)}):
              var typesStr: String = annaLang.printer.printExpr(types);
              [typesStr.substr(1, typesStr.length - 2), body];
            case e:
              MacroLogger.log(e, 'e');
              MacroLogger.logExpr(params, 'params');
              throw new ParsingException("AnnaLang: Expected parenthesis");
          }
          #if !macro
          var paramsStr: String = typesAndBody[0];
          paramsStr = paramsStr.substr(1, paramsStr.length - 2);
          var paramsStrs = paramsStr.split(',');
          for(pStr in paramsStrs) {
            var typeAndName = pStr.split(':');
            var typeString: String = StringTools.trim(typeAndName[0]);
            if(typeString.length > 0) {
              paramTypeStrings.push(typeString);
              var paramName: String = StringTools.trim(typeAndName[1]);
              paramNameStrings.push(paramName);
              macroContext.varTypesInScope.set(paramName, typeString);
            }
          }
          #end
          var haxeStr: String = '${anonFunctionName}(${typesAndBody[0]}, ${annaLang.printer.printExpr(typesAndBody[1])});';
          var expr = annaLang.macros.haxeToExpr(haxeStr);
          defined = Def.defineFunction(annaLang, expr);
          defined.varTypesInScope = macroContext.varTypesInScope;
        }
        #if !macro
        var terms: Array<Dynamic> = cast(defined.funBody, Array<Dynamic>);
        var allOps: Array<vm.Operation> = [];
        for(term in terms) {
          var operations = annaLang.lang.resolveOperations(cast term);
          allOps = allOps.concat(operations);
        }
        var anonFn: vm.Function = new vm.SimpleFunction();
        var scope: String = 'scope';
        if(paramTypeStrings.length > 0) {
          scope = ', ${scope}';
        }
        var anonFnString: String = 'function(${paramNameStrings.join(', ')}${scope}) {
          return allOps;
        }';
        var ast = new hscript.Parser().parseString(anonFnString);
        var interp = new hscript.Interp();
        interp.variables.set('allOps', allOps);
        anonFn.fn = interp.execute(ast);
        anonFn.args = paramNameStrings;
        anonFn.scope = vm.Process.self().processStack.getVariablesInScope();
        anonFn.apiFunc = Atom.create(macroContext.currentFunction);
        macroContext.lastFunctionReturnType = "vm_Function";
        var paramsTypesString: String = '';
        if(paramTypeStrings.length > 0) {
          paramsTypesString = '_${paramTypeStrings.join('_')}';
        }
        vm.Classes.defineFunction(Atom.create(currentModuleStr), Atom.create(anonFunctionName + paramsTypesString), anonFn);
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