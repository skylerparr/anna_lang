package lang.macros;

import lang.macros.AnnaLang;
import haxe.macro.Expr;
import haxe.macro.Printer;
class Const {
  public static function gen(annaLang: AnnaLang, params: Expr): Array<Expr> {
    var printer = annaLang.printer;
    var macroContext: MacroContext = annaLang.macroContext;

    switch(params.expr) {
      case EBinop(OpAssign, {expr: EConst(CIdent(varName))}, value):
        macroContext.currentModuleDef.constants.set(varName, printer.printExpr(value));
      case _:
        MacroLogger.log(params, 'params');
        MacroLogger.logExpr(params, 'params');
        throw "AnnaLang: Unexpected contant syntax for ${printer.printExpr(params)} at line ${annaLang.macroTools.getLineNumberFromContext()}";
    }
    return [];
  }
}