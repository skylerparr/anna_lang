package ;

#if (cpp || cppia)
import haxe.io.Output;
import sys.io.File;
#end
import lang.macros.AnnaLang;
import haxe.macro.Expr;

using haxe.macro.Tools;

class Logger {

  private inline static var filePath: String = 'log.txt';

  #if (!macro && cpp)
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
    #if cpp
    sys.io.File.saveContent(filePath, '');
//    logThread = cpp.vm.Thread.create(logListener);
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

  macro public static function log(term: Expr, label: Expr = null): Expr {
    var locStr: String = '${haxe.macro.Context.currentPos()}';
    var frags: Array<String> = locStr.split('/');
    frags = frags[frags.length - 1].split(':');
    var position: Expr = AnnaLang.annaLangForMacro.macros.haxeToExpr('"${frags[0]}:${frags[1]}"');
    return macro {};
    return macro {
      var pid: Pid = vm.Process.self();
      var labelStr: String = '';
      if($e{label} != null) {
        labelStr = $e{label} + ': ';
      }
      var log: String = $e{position} + ':' + labelStr + Anna.toAnnaString(pid) + Anna.toAnnaString($e{term}) + '\r\n';
//      cpp.Lib.print(log);
      Logger.sendLog(log);
    }
  }

}
