package lang.macros;
import lang.macros.AnnaLang;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;
class Impl {
  public function new() {
  }

  public static function gen(annaLang: AnnaLang, params: Expr): Array<Expr> {
    var iface = annaLang.macroTools.getIdent(params);
    annaLang.macroContext.currentModuleDef.interfaces.push(iface);
    return [];
  }
}
