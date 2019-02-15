package ;

import compiler.CodeGen;
import compiler.Compiler;
import haxe.macro.Expr;
import hscript.Interp;
import hscript.Parser;
using lang.AtomSupport;
@:build(macros.ValueClassImpl.build())
class Anna {
  @field public static var parser: Parser;
  @field public static var interp: Interp;

  public static function start():Atom {
    parser = Native.callStaticField('Main', 'parser');
    interp = Native.callStaticField('Main', 'interp');
    Compiler.start();
    return 'ok'.atom();
  }

  public static function add(a: Int, b: Int): Int {
    return a+b;
  }

  public static function subtract(a: Int, b: Int): Int {
    return a-b;
  }

  public static function rem(a: Int, b: Int): Int {
    return a%b;
  }

  public static function quote(body: Expr): #if macro haxe.macro.Expr #else hscript.Expr #end {
    return null;
  }

}
