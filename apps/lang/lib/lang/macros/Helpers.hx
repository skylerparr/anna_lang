package lang.macros;
import haxe.macro.Expr.TypeDefinition;
import lang.macros.AnnaLang;
import lang.macros.MacroContext;
class Helpers {

  public static function getType(type: String, macroContext: MacroContext):String {
    return switch(type) {
      case "Int" | "Float":
        "Number";
      case null:
        getAlias(macroContext.lastFunctionReturnType, macroContext);
      case _:
        type;
    }
  }

  public static function getAlias(str: String, macroContext: MacroContext):String {
    return switch(macroContext.aliases.get(str)) {
      case null:
        str;
      case val:
        val;
    }
  }

  public static inline function makeFqFunName(funName: String, types: Array<String>):String {
    var spacer: String = '_';
    if(types.length == 0) {
      spacer = '';
    }
    return '${funName}${spacer}${sanitizeArgTypeNames(types)}';
  }

  public static function sanitizeArgTypeNames(types: Array<String>):String {
    return StringTools.replace(types.join("_"), ".", "_");
  }

  public static function applyBuildMacro(annaLang: AnnaLang, cls: TypeDefinition):Void {
    var macroTools: MacroTools = annaLang.macroTools;

    var metaConst = macroTools.buildConst(CIdent('lang.macros.Macros'));
    var metaField = macroTools.buildExprField(metaConst, 'build');
    var metaCall = macroTools.buildCall(metaField, []);
    var metaData = macroTools.buildMeta(':build', [metaCall]);
    macroTools.addMetaToClass(cls, metaData);
  }
}
