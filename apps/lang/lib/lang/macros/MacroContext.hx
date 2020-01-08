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
  public static var varTypesInScope: Map<String, String>;
  public static var lastFunctionReturnType: String;

  public static var associatedInterfaces: Map<String, String> = new Map<String, String>();
  @:isVar
  public static var declaredClasses(get, set): Map<String, ModuleDef>;
  public static var declaredInterfaces: Map<String, ModuleDef>;

  @:isVar
  public static var currentModuleDef(get, set):ModuleDef;

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

  static function get_currentModuleDef():ModuleDef {
    if(currentModuleDef == null) {
      currentModuleDef = defaultModuleDef;
    }
    return currentModuleDef;
  }

  static function set_currentModuleDef(value:ModuleDef):ModuleDef {
    return currentModuleDef = value;
  }

  static function get_declaredClasses():Map<String, ModuleDef> {
    if(declaredClasses == null) {
      declaredClasses = new Map<String, ModuleDef>();
    }
    return declaredClasses;
  }

  static function set_declaredClasses(value:Map<String, ModuleDef>):Map<String, ModuleDef> {
    return declaredClasses = value;
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

  public static var defaultModuleDef: ModuleDef = new ModuleDef("__DEFAULT_MODULE__");

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

