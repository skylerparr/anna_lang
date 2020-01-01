package lang.macros;
import haxe.io.Output;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Printer;
import haxe.macro.Expr.Field;
import haxe.macro.Expr;
class MacroLogger {

  #if macro
  public static var init: Bool = false;

  public static function log(message: Dynamic, label: String = null): Void {
    if(!init) {
      File.saveContent('${Sys.getCwd()}log', '');
      init = true;
    }
    if(label != null) {
      label = '${label}: ';
    } else {
      label = '';
    }

    var output: Output = File.append('${Sys.getCwd()}log', false);
    output.writeString(label);
    output.writeString(message + '');
    output.writeString('\n');
    output.close();
  }

  public static function printFields(fields: Array<Field>):Void {
    var p: Printer = new Printer();
    for(field in fields) {
      MacroLogger.log(p.printField(field));
    }
  }

  public static function logExpr(expr: Expr, label: String = null): Void {
    var p: Printer = new Printer();
    MacroLogger.log(p.printExpr(expr), label);
  }
  #else
  public static function log(message: Dynamic, label: String = null): Void {
  }

  public static function printFields(fields: Array<Field>):Void {
  }

  public static function logExpr(expr: Expr, label: String = null): Void {
  }
  #end
}
