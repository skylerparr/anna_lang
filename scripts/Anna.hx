package ;

import compiler.CodeGen;
import compiler.Compiler;
import haxe.macro.Expr;
import hscript.Interp;
import hscript.Parser;
import lang.Types.Atom;
using lang.AtomSupport;
@:build(macros.ValueClassImpl.build())
class Anna {
  @field public static var parser: Parser;
  @field public static var interp: Interp;

  @field public static var aliases: Map<Atom, Atom>;

  public static function start():Atom {
    parser = Native.callStaticField('Main', 'parser');
    interp = Native.callStaticField('Main', 'interp');
    aliases = new Map<Atom, Atom>();
    Compiler.start();
    Code.start();
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

  public static function foo(args: Array<Dynamic>): Void {
    trace("foo");
  }

  public static function fn(args: Expr, body: Expr): Dynamic {
    return Compiler.fn();
  }

  public static function quote(body: Expr): #if macro haxe.macro.Expr #else hscript.Expr #end {
    return null;
  }

  public static function alias(from: Atom, to: Atom): Atom {
    aliases.set(from, to);
    return 'ok'.atom();
  }

  public static function body(body: String): #if macro haxe.macro.Expr #else hscript.Expr #end {
    var hasParens: Bool = false;
    var index: Int = 0;
    for(i in 0...body.length) {
      var char = body.charAt(i);
      if(char == '(') {
        hasParens = true;
        break;
      }
      index = i;
    }
    var funName: String = body.substr(0, index + 1);
    var args: String = body.substr(index + 1);
    var fun: Atom = aliases.get(funName.atom());
    if(fun == null) {
      fun = funName.atom();
    }
    var b: String = 'Anna.${fun.value}${args}';
    #if macro
      return CodeGen._parse(b);
    #else
      return CodeGen.parse(b);
    #end
  }
}
