package macros;

import haxe.macro.Context;
import haxe.macro.Expr;
class AnnaMacros {
  public static function main() {

  }

  macro public static function runMacro(): Expr {
    var pos: haxe.macro.Position = Context.currentPos();
    return { pos : pos, expr : EConst(CString("snake")) };
  }
}