package compiler;

import hscript.Parser;
import haxe.macro.Context;
import haxe.macro.Expr;
class CodeGen {

  public static function main(): Void {
    
  }

  private static inline var fnBody: String = "function(args: Array<Dynamic>) {
      return 'yo';
    }";


  macro public static function fn(): Expr {
    return Context.parse(fnBody, Context.currentPos());
  }

  public static function _fn(): hscript.Expr {
    var parser: Parser = Native.callStaticField('Main', 'parser');
    return parser.parseString(fnBody);
  }

  macro public static function parse(s: String): Expr {
    return Context.parse(s, Context.currentPos());
  }

  public static function _parse(string: String): hscript.Expr {
    var parser: Parser = Native.callStaticField('Main', 'parser');
    return parser.parseString(string);
  }
}