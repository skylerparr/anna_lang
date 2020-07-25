package lang.macros;
import lang.macros.AnnaLang;
import haxe.macro.Expr;

class Alias {

  public static function gen(annaLang:AnnaLang, params: Expr): Array<Expr> {
    var macroTools = annaLang.macroTools;
    var fun = macroTools.getCallFunName(params);
    var fieldName = macroTools.getAliasName(params);

    annaLang.macroContext.aliases.set(fieldName, fun);
    return [];
  }

}