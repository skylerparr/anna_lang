package lang.macros;

import lang.macros.MacroTools;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;

class Fn {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  public static function gen(params: Expr): Array<Expr> {
    MacroContext.lastFunctionReturnType = "vm_Function";
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
              var typesStr: String = printer.printExpr(types);
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
            paramTypeStrings.push(typeString);
            var paramName: String = StringTools.trim(typeAndName[1]);
            paramNameStrings.push(paramName);
            MacroContext.varTypesInScope.set(paramName, typeString);
          }
          #end
          var haxeStr: String = '${anonFunctionName}(${typesAndBody[0]}, ${printer.printExpr(typesAndBody[1])});';
          var expr = lang.macros.Macros.haxeToExpr(haxeStr);
          defined = Def.defineFunction(expr);
        }
        #if !macro
        var terms: Array<Dynamic> = cast(defined.funBody, Array<Dynamic>);
        var allOps: Array<vm.Operation> = [];
        for(term in terms) {
          var operations = vm.Lang.resolveOperations(cast term);
          allOps = allOps.concat(operations);
        }
        var anonFn: vm.Function = new vm.SimpleFunction();
        anonFn.fn = function(args, scope) {
          return allOps;
        }
        anonFn.args = paramNameStrings;
        anonFn.scope = vm.Process.self().processStack.getVariablesInScope();
        anonFn.apiFunc = Atom.create(MacroContext.currentFunction);
        vm.Classes.defineFunction(Atom.create(currentModuleStr), Atom.create(anonFunctionName + '_${paramTypeStrings.join('_')}'), anonFn);
        #end
        var haxeStr: String = 'ops.push(new vm.DeclareAnonFunction(
              ${MacroTools.getAtom('${currentModuleStr}.${defined.internalFunctionName}')},
              ${MacroTools.getAtom(currentModuleStr)},
              ${MacroTools.getAtom(MacroContext.currentFunction)},
              ${MacroTools.getLineNumber(params)}))';
        return [lang.macros.Macros.haxeToExpr(haxeStr)];
      case _:
        MacroLogger.log(params, 'params');
        MacroLogger.logExpr(params, 'params');
        throw new ParsingException("AnnaLang: Expected block");
    }
  }
}