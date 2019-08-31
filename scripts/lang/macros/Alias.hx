package lang.macros;
import haxe.macro.Expr;
import hscript.plus.ParserPlus;
import haxe.macro.Printer;
import haxe.macro.Context;

class Alias {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  #if macro
  public static function gen(params: Expr): Array<Expr> {
    var fun = MacroTools.getCallFunName(params);
    var fieldName = MacroTools.getAliasName(params);

    MacroContext.aliases.set(fieldName, fun);
    return [];
  }
  #end
}