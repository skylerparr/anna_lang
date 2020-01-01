package vm;
import lang.macros.AnnaLang;
import vm.Operation;
import haxe.macro.Printer;
import haxe.macro.Expr;
import hscript.Macro;
import hscript.Parser;
using lang.AtomSupport;
class Lang {

  private static var printer: Printer = new Printer();
  private static var parser: Parser = {
    var parser: Parser = new Parser();
    parser.allowMetadata = true;
    parser.allowTypes = true;
    parser;
  }

  public inline static function eval(string:String):Tuple {
    try {
      var ast = parser.parseString(string);
      var pos = { max: 12, min: 0, file: null };
      var ast: Expr = new Macro(pos).convert(ast);
      invokeAst(ast);
      return Tuple.create(['ok'.atom(), ast]);
    } catch(e: Dynamic) {
      return Tuple.create(['error'.atom(), '${e}']);
    }
  }

  public inline static function invokeAst(ast: Expr): Atom {
    switch ast {
      // handle defines here
      // ex: case "defCls":
      // ex: case "defType":
      // etc.
      case _:
        trace(ast);
        var exprs: Array<Expr> = AnnaLang.walkBlock(ast);
        trace(exprs);
    }
    return 'ok'.atom();
  }
}
