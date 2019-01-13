package macros;
#if macro
import haxe.io.Output;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Printer;
import haxe.macro.Expr.Field;
#end
class MacroLogger {

  public static function main(): Void {

  }
  
  #if macro
  public static var init: Bool = false;

  public static function log(message: Dynamic): Void {
    if(!init) {
      File.saveContent('${Sys.getCwd()}log', '');
      init = true;
    }

    var output: Output = File.append('${Sys.getCwd()}log', false);
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

  #end
}
