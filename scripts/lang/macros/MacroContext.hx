package lang.macros;

import haxe.macro.Expr.TypeDefinition;
class MacroContext {
  public static var currentModule: TypeDefinition;
  public static var currentFunction: String;
}