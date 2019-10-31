package ;

import haxe.macro.Expr;

using haxe.macro.Tools;

class Logger {

  public static function inspect(term: Dynamic, label: String = null): Void {
    var labelStr: String = '';
    if(label != null) {
      labelStr = label + ': ';
    }
    #if cpp
    cpp.Lib.print(labelStr + Anna.toAnnaString(term) + '\r\n');
    #else
    trace(labelStr + Anna.toAnnaString(term) + '\r\n');
    #end
  }

}