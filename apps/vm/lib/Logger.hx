package ;

#if (cpp || cppia)
import haxe.io.Output;
import sys.io.File;
#end
import haxe.macro.Expr;

using haxe.macro.Tools;

class Logger {

  private inline static var filePath: String = 'log.txt';

  #if !macro
  private static var logThread: cpp.vm.Thread;

  public static function sendLog(log: String): Void {
    logThread.sendMessage(log);
  }

  private static function logListener():Void {
    while(true) {
      var log: String = cpp.vm.Thread.readMessage(true);
      var output: haxe.io.Output = sys.io.File.append('log.txt');
      output.writeString(log);
      output.close();
    }
  }
  #end

  public static function init():Void {
    #if !macro
    #if (cpp || cppia)
    sys.io.File.saveContent(filePath, '');
    logThread = cpp.vm.Thread.create(logListener);
    #end
    #end
  }

  public static function inspect(term: Dynamic, label: String = null): Void {
    var labelStr: String = '';
    if(label != null) {
      labelStr = label + ': ';
    }
    #if cpp
    var log: String = labelStr + Anna.toAnnaString(term) + '\r\n';
    cpp.Lib.print(log);
    #else
    trace(labelStr + Anna.toAnnaString(term) + '\r\n');
    #end
  }

  #if (cpp || cppia)
  macro public static function log(term: Expr, label: Expr = null): Expr {
    var locStr: String = '${haxe.macro.Context.currentPos()}';
    var frags: Array<String> = locStr.split('/');
    frags = frags[frags.length - 1].split(':');
    var position: Expr = lang.macros.Macros.haxeToExpr('"${frags[0]}:${frags[1]}"');
    return macro {
      var labelStr: String = '';
      if($e{label} != null) {
        labelStr = $e{position} + ':' + $e{label} + ': ';
      }
      var log: String = labelStr + Anna.toAnnaString($e{term}) + '\r\n';
      cpp.Lib.print(log);
      Logger.sendLog(log);
    }
  }
  #else
  macro public static function log(term: Expr, label: Expr = null): Expr {
    return macro{};
  }
  #end

}