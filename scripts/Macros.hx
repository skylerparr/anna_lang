package;

import haxe.macro.Context;
import lang.macros.MacroLogger;
import haxe.macro.Expr;

//  =>
// #pos\(.*?\)
class Macros {
  macro public static function ei(expr: Expr): Expr {
    var retVal = macro {
      EitherMacro.gen(cast($e{expr}, Array<Dynamic>));
    };

    return retVal;
  }
}