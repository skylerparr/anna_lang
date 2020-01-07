package lang.macros;
import haxe.macro.Expr;
import haxe.macro.Type;

class MacroContext {
  @:isVar
  public static var currentModule(get, set): TypeDefinition;
  @:isVar
  public static var currentFunction(get, set): String;
  public static var currentVar: String;
  public static var aliases: Map<String, String>;
  public static var currentFunctionArgTypes: Array<String>;
  public static var returnTypes: Array<String>;
  public static var declaredFunctions: Map<String, Array<Dynamic>>;
  public static var varTypesInScope: Map<String, String>;
  public static var lastFunctionReturnType: String;
  public static var declaredClasses: Map<String, ModuleDef>;
  public static var declaredInterfaces: Map<String, ModuleDef>;
  public static var currentModuleDef: ModuleDef;

  private static function get_currentModule(): TypeDefinition {
    if(currentModule == null) {
      currentModule = defaultTypeDefinition;
    }
    return currentModule;
  }

  private static function set_currentModule(mod: TypeDefinition): TypeDefinition {
    currentModule = mod;
    return currentModule;
  }

  static function get_currentFunction(): String {
    if(currentFunction == null) {
      currentFunction = "__default__";
    }
    return currentFunction;
  }

  static function set_currentFunction(value: String): String {
    return currentFunction = value;
  }

  public static var defaultTypeDefinition: TypeDefinition =
  {
    defaultTypeDefinition = {
      pack: ["dkjf", "skljf", "kopaioe", "odfkpewp"],
      name: "__DefaultType__",
      pos: currentPos(),
      kind: TDStructure,
      fields: []
    }
  }

  #if macro
  public static function currentPos():Dynamic {
    return haxe.macro.Context.currentPos();
  }
  #else
  public static function currentPos():Position {
    return {file: "none:0", min: 0, max: 0};
  }
  #end

  #if macro
  public static function typeof(expr: Expr):Type {
    return haxe.macro.Context.typeof(expr);
  }
  #else
  public static function typeof(expr: Expr):Type {
    return TDynamic(null);
  }
  #end

  #if macro
  public static function defineType(cls: TypeDefinition):Void {
    return haxe.macro.Context.defineType(cls);
  }
  #else
  public static function defineType(cls: TypeDefinition):Void {

  }
  #end

  #if macro
  public static function makeExpr(v:Dynamic, pos:Position):Expr {
    return haxe.macro.Context.makeExpr(v, pos);
  }
  #else
  public static function makeExpr(v:Dynamic, pos:Position):Expr {
    return macro{};
  }
  #end
}

