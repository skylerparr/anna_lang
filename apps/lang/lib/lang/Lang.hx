package lang;
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

  public static inline function stringToAst(string:String):Tuple {
    try {
      var ast = parser.parseString(string);
      var pos = { max: 12, min: 0, file: null };
      var ast: Expr = new Macro(pos).convert(ast);
      var anna_ast: Tuple = parseHaxeAst(ast);
      return Tuple.create(['ok'.atom(), anna_ast]);
    } catch(e: Dynamic) {
      return Tuple.create(['error'.atom(), '${e}']);
    }
  }

  private static function parseHaxeAst(haxeAst: Expr): Tuple {
    return switch(haxeAst.expr) {
      case EConst(CIdent(varName)):
        Tuple.create([Tuple.create(['var'.atom(), varName]), 'Dynamic'.atom(), 0]);
      case EConst(CString(v)):
        Tuple.create([Tuple.create(['const'.atom(), '${v}']), 'String'.atom(), 0]);
      case EConst(CInt(v)) | EConst(CFloat(v)):
        Tuple.create([Tuple.create(['const'.atom(), Std.parseFloat(v)]), 'Number'.atom(), 0]);
      case EMeta({name: '_'}, {expr: EConst(CString(v))}):
        Tuple.create([Tuple.create(['const'.atom(), v.atom()]), 'Atom'.atom(), 0]);
      case EArrayDecl(values):
        var v: Array<Any> = [];
        var exprs: Array<Dynamic> = cast(values, Array<Dynamic>);
        for(value in exprs) {
          v.push(parseHaxeAst(value));
        }
        Tuple.create([Tuple.create(['const'.atom(), Tuple.create(v)]), 'Tuple'.atom(), 0]);
      case EBlock(values):
        var v: Array<Any> = [];
        var exprs: Array<Dynamic> = cast(values, Array<Dynamic>);
        for(value in exprs) {
          v.push(parseHaxeAst(value));
        }
        Tuple.create([Tuple.create(['const'.atom(), Tuple.create(v)]), 'LList'.atom(), 0]);
      case EObjectDecl(values):
        var v: Array<Any> = [];
        var exprs: Array<Dynamic> = cast(values, Array<Dynamic>);
        for(value in exprs) {
          v.push(Tuple.create([Tuple.create([Tuple.create(['const'.atom(), Atom.create(value.field)]), 'Atom'.atom(), 0]), parseHaxeAst(value.expr)]));
        }
        Tuple.create([Tuple.create(['const'.atom(), Tuple.create(v)]), 'Keyword'.atom(), 0]);
      case EBinop(OpArrow, )
      case e:
        throw new ParsingException('Unexpected expression ${e}');
    }
  }
}
