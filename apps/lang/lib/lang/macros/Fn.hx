package lang.macros;

import lang.macros.AnnaLang;
import lang.macros.AnnaLang;
import haxe.CallStack;
import lang.macros.MacroTools;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;

class Fn {
  public static function gen(params: Expr): Array<Expr> {
    var currentModule: TypeDefinition = MacroContext.currentModule;
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
              var typesStr: String = AnnaLang.printer.printExpr(types);
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
              MacroContext.varTypesInScope.set(paramName, typeString);
            }
          }
          #end
          var haxeStr: String = '${anonFunctionName}(${typesAndBody[0]}, ${AnnaLang.printer.printExpr(typesAndBody[1])});';
          var expr = lang.macros.Macros.haxeToExpr(haxeStr);
          defined = Def.defineFunction(expr);
          defined.varTypesInScope = MacroContext.varTypesInScope;
        }
        #if !macro
        var terms: Array<Dynamic> = cast(defined.funBody, Array<Dynamic>);
        var allOps: Array<vm.Operation> = [];
        for(term in terms) {
          var operations = vm.Lang.resolveOperations(cast term);
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
        anonFn.apiFunc = Atom.create(MacroContext.currentFunction);
        MacroContext.lastFunctionReturnType = "vm_Function";
        var paramsTypesString: String = '';
        if(paramTypeStrings.length > 0) {
          paramsTypesString = '_${paramTypeStrings.join('_')}';
        }
        vm.Classes.defineFunction(Atom.create(currentModuleStr), Atom.create(anonFunctionName + paramsTypesString), anonFn);
        #end
        MacroContext.lastFunctionReturnType = "vm_Function";
        return [buildDeclareAnonFunctionExpr(currentModuleStr, defined.internalFunctionName,params)];
      case _:
        MacroLogger.log(params, 'params');
        MacroLogger.logExpr(params, 'params');
        throw new ParsingException("AnnaLang: Expected block");
    }
  }

  public static function buildDeclareAnonFunctionExpr(currentModuleStr: String,
                                                      internalFunctionName: String,
                                                      params): Expr {
    return macro ops.push(new vm.DeclareAnonFunction(
      $e{MacroTools.getAtomExpr('${currentModuleStr}.${internalFunctionName}')},
      $e{MacroTools.getAtomExpr(currentModuleStr)},
      $e{MacroTools.getAtomExpr(MacroContext.currentFunction)},
      $e{MacroTools.buildConst(CInt(MacroTools.getLineNumber(params) + ''))}));
  }
}