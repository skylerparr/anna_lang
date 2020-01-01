package lang.macros;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;

class Alias {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  public static function gen(params: Expr): Array<Expr> {
    var fun = MacroTools.getCallFunName(params);
    var fieldName = MacroTools.getAliasName(params);

    MacroContext.aliases.set(fieldName, fun);
    return [];
  }

}