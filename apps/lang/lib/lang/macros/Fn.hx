package lang.macros;

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

  #if macro
  public static function gen(params: Expr): Array<Expr> {
    MacroLogger.logExpr(params, 'anonymous fn params');
    MacroContext.lastFunctionReturnType = "vm_Function";
    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
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
          var haxeStr: String = '${anonFunctionName}(${typesAndBody[0]}, ${printer.printExpr(typesAndBody[1])});';
          var expr = lang.macros.Macros.haxeToExpr(haxeStr);
          defined = Def.defineFunction(expr);
        }
        var haxeStr: String = 'ops.push(new vm.DeclareAnonFunction(@atom "${currentModuleStr}.${defined.internalFunctionName}", @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${MacroTools.getLineNumber(params)}))';
        return [lang.macros.Macros.haxeToExpr(haxeStr)];
      case _:
        MacroLogger.log(params, 'params');
        MacroLogger.logExpr(params, 'params');
        throw new ParsingException("AnnaLang: Expected block");
    }
  }
  #end
}