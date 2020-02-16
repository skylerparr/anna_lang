package lang.macros;
import haxe.CallStack;
import haxe.rtti.Rtti;
import haxe.macro.Expr;

class MacroContext {
  @:isVar
  public static var currentModule(get, set): TypeDefinition;
  @:isVar
  public static var currentFunction(get, set): String;
  public static var currentVar: String;
  public static var aliases: Map<String, String> = new Map<String, String>();
  public static var currentFunctionArgTypes: Array<String>;

  @:isVar
  public static var varTypesInScope(get, set): VarTypesInScope;

  @:isVar
  public static var lastFunctionReturnType(get, set): String;
  public static var associatedInterfaces: Map<String, String> = new Map<String, String>();
  public static var declaredClasses: Map<String, ModuleDef> = new Map<String, ModuleDef>();
  public static var declaredInterfaces: Map<String, ModuleDef> = new Map<String, ModuleDef>();

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

  static function get_varTypesInScope(): VarTypesInScope {
    if(varTypesInScope == null) {
      varTypesInScope = new VarTypesInScope();
    }
    return varTypesInScope;
  }

  static function set_varTypesInScope(value: VarTypesInScope): VarTypesInScope {
    return varTypesInScope = value;
  }

  static function get_lastFunctionReturnType(): String {
    return lastFunctionReturnType;
  }

  static function set_lastFunctionReturnType(value: String): String {
    return lastFunctionReturnType = value;
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
  public static function typeof(expr: Expr):haxe.macro.Type {
    return haxe.macro.Context.typeof(expr);
  }
  #else
  public static function typeof(expr: Expr):haxe.macro.Type {
    return TLazy(function() {
      trace("here");
      return TDynamic(null);
    });
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

