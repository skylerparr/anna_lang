package lang.macros;
import haxe.macro.Expr;
import haxe.macro.Type;

class MacroContext {
  public static var currentModule: TypeDefinition;
  public static var currentFunction: String;
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

  #if macro
  public static function currentPos():Dynamic {
    return haxe.macro.Context.currentPos();
  }
  #else
  public static function currentPos():Position {
    return {file: "none:43", min: 0, max: 0};
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

