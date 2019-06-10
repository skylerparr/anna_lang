package;

import lang.macros.MacroLogger;
import haxe.macro.Context;
import lang.macros.MacroLogger;
import haxe.macro.Expr;

//  =>
// #pos\(.*?\)
class Macros {

  macro public static function build(): Array<Field> {
    var fields: Array<Field> = Context.getBuildFields();
    for(field in fields) {
      MacroLogger.log(field);
    }
    return fields;
  }

  macro public static function ei(expr: Expr): Expr {
    var retVal = macro {
      EitherMacro.gen(cast($e{expr}, Array<Dynamic>));
    };

    return retVal;
  }

  macro public static function tuple(expr: Expr): Expr {
    return macro {
      Tuple.create(EitherMacro.gen(cast($e{expr}, Array<Dynamic>)));
    }
  }
}