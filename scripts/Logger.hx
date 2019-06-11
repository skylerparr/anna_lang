package;

import lang.macros.MacroLogger;
import haxe.macro.Expr;

using haxe.macro.Tools;

class Logger {

  macro public static function inspect(term: Expr, label: Expr = null): Expr {
    var strLabel: String = switch(label.expr) {
      case EConst(CString(s)):
        s;
      case _:
        null;
    }
    if(strLabel == null) {
      strLabel = '';
    } else {
      strLabel = '${strLabel}: ';
    }

    var pos = '${term.pos}'.split(':');
    var line = pos[1];
    var file = pos[0].split('/');
    var fileString = file[file.length - 1];

    var retVal = macro {
      var strTerm: String = Anna.inspect($term);
      cpp.Lib.print('${$i{fileString}}:${$i{line}}: ${$i{strLabel}}' + strTerm + '\n\r');
    }
    return retVal;
  }

}