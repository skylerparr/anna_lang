package lang.macros;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;
class Impl {
  public function new() {
  }

  public static function gen(params: Expr): Array<Expr> {
    var iface = MacroTools.getIdent(params);
    MacroContext.currentModuleDef.interfaces.push(iface);
    return [];
  }
}
