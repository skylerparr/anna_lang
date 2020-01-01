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


}
