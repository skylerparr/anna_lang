package compiler;
import hscript.plus.ParserPlus;
import hscript.Macro;
import hscript.Interp;
import vm.PushStack;
using lang.AtomSupport;
class Code {
  private static var parser: ParserPlus =
  {
    parser = new ParserPlus();
    parser.allowMetadata = true;
    parser.allowTypes = true;
    parser;
  }

  public static function interpString(string: String): Dynamic {
    var ast = parser.parseString(string);
    var pos = { max: 12, min: 0, file: null };
    var ast = new Macro(pos).convert(ast);
    trace(ast);

//    var scopeVars: Map<String, Dynamic> = new Map<String, Dynamic>();
//    var op: PushStack = new PushStack('System'.atom(), 'echo_String'.atom(), LList.create([Tuple.create(['const'.atom(), string])]), 'Code'.atom(), 'interpString'.atom(), 13);
//    op.execute(scopeVars, vm.Process.self().processStack);
    return string;
  }
}
