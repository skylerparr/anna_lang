package lang.macros;

import haxe.macro.Expr;
import haxe.macro.Expr.TypeDefinition;
class MacroContext {
  #if macro
  public static var currentModule: TypeDefinition;
  public static var currentFunction: String;
  public static var currentVar: String;
  public static var aliases: Map<String, String>;
  public static var currentFunctionArgTypes: Array<String>;
  public static var declaredVars: Array<Dynamic>;
  public static var returnTypes: Array<String>;
  public static var declaredFunctions: Map<String, Array<Expr>>;
  #end

  public static function define_callback(currentClass: Atom, callbackName: Atom):Void {
//    Logger.inspect(currentClass, 'currentClass');
//    Logger.inspect(callbackName, 'callbackName');
  }
}