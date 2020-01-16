package lang.macros;

import haxe.macro.Expr;
import hscript.plus.ParserPlus;
import haxe.macro.Printer;
class Const {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  public static function gen(params: Expr): Array<Expr> {
    switch(params.expr) {
      case EBinop(OpAssign, {expr: EConst(CIdent(varName))}, value):
        MacroContext.currentModuleDef.constants.set(varName, printer.printExpr(value));
      case _:
        MacroLogger.log(params, 'params');
        MacroLogger.logExpr(params, 'params');
        throw "AnnaLang: Unexpected contant syntax for ${printer.printExpr(params)} at line ${MacroTools.getLineNumberFromContext()}";
    }
    return [];
  }
}