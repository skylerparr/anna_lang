package lang.macros;
import haxe.io.Output;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Printer;
import haxe.macro.Expr.Field;
import haxe.macro.Expr;
class MacroLogger {

  #if macro
  public static var isInit: Bool = false;
  private static var p: Printer = new Printer();
  private static var output: Output;

  public static function init() {
    if(!isInit) {
      File.saveContent('${Sys.getCwd()}log', '');
      isInit = true;
      output = File.append('${Sys.getCwd()}log', false);
    }
  }

  public static function close() {
    if(!isInit) {
      return;
    }
    isInit = false;
    output.close();
  }

  public static function log(message: Dynamic, label: String = null): Void {
    writeLog(message, label);
  }

  public static function printFields(fields: Array<Field>):Void {
    for(field in fields) {
      writeLog(p.printField(field));
    }
  }

  public static function logExpr(expr: Expr, label: String = null): Void {
    writeLog(p.printExpr(expr), label);
  }

  private inline static function writeLog(message: Dynamic, label: String = null): Void {
    if(!isInit) {
      return;
    }
    if(label != null) {
      label = '${label}: ';
    } else {
      label = '';
    }

    output.writeString(label);
    output.writeString(message + '');
    output.writeString('\n');
  }
  #else
  public static function init() {
  }

  public static function close() {
  }

  public static function log(message: Dynamic, label: String = null): Void {
    return;
    if(label != null) {
      label = '${label}: ';
    } else {
      label = '';
    }
    cpp.Lib.println(label + message);
  }

  public static function printFields(fields: Array<Field>):Void {
  }

  public static function logExpr(expr: Expr, label: String = null): Void {
    return;
    if(label != null) {
      label = '${label}: ';
    } else {
      label = '';
    }
    var p: Printer = new Printer();
    cpp.Lib.println(label + p.printExpr(expr));

  }
  #end
}
