package ;

#if cpp
import haxe.io.Output;
import sys.io.File;
#end
import haxe.macro.Expr;

using haxe.macro.Tools;

class Logger {

  private inline static var filePath: String = 'log.txt';

  public static function init():Void {
    #if cpp
    File.saveContent(filePath, '');
    #end
  }

  public static function inspect(term: Dynamic, label: String = null, toFile: Bool = false): Void {
    var labelStr: String = '';
    if(label != null) {
      labelStr = label + ': ';
    }
    #if cpp
    var log: String = labelStr + Anna.toAnnaString(term) + '\r\n';
    if(toFile) {
      var output: Output = File.append(filePath);
      output.writeString(log);
      output.close();
    } else {
      cpp.Lib.print(log);
    }
    #else
    trace(labelStr + Anna.toAnnaString(term) + '\r\n');
    #end
  }

}