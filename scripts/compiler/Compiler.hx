package compiler;

import hscript.Parser;
import hscript.Interp;
import hscript.Printer;
using lang.AtomSupport;
using StringTools;

@:build(lang.macros.ValueClassImpl.build())
class Compiler {
  @field public static var parser: Parser;
  @field public static var interp: Interp;
  @field public static var printer: Printer;

  public static function start(): Atom {
    printer = new Printer();
    parser = Native.callStaticField('Main', 'parser');
    interp = Native.callStaticField('Main', 'interp');
    return 'ok'.atom();
  }

  public static function subscribeAfterCompile(fun: Void -> Void): Atom {
    Native.callStaticField("Main", "compilerCompleteCallbacks").push(fun);
    return 'ok'.atom();
  }
}