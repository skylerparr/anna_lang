package lang.macros;
import haxe.macro.Expr.TypeDefinition;
import lang.macros.AnnaLang;
import lang.macros.MacroContext;
class Helpers {

  public static function getType(type: String, macroContext: MacroContext):String {
    return switch(StringTools.trim(type)) {
      case "Int" | "Float":
        "Number";
      case null:
        getAlias(macroContext.lastFunctionReturnType, macroContext);
      case "AnnaList_Any":
        "LList";
      case "vm.Function" | "vm.AnonFn" | "vm_Function" | "vm_AnonFn":
        "vm.Function";
      case "AnnaMap_Any_Any":
        "MMap";
      case _:
        type;
    }
  }

  public static inline function getCustomType(type: String, macroContext: MacroContext): String {
    if(macroContext.typeFieldMap.exists(type)) {
      return "lang.UserDefinedType";
    } else {
      return type;
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

  public static inline function generatePermutations(lists:Array<Array<String>>, result: Array<Array<String>>, depth: Int, current: Array<String>):Void {
    var solutions: Int = 1;
    for(i in 0...lists.length) {
      solutions *= lists[i].length;
    }
    for(i in 0...solutions) {
      var j: Int = 1;
      var items: Array<String> = [];
      for(item in lists) {
        items.push(item[Std.int(i/j) % item.length]);
        j *= item.length;
      }
      result.push(items);
    }
  }
}
