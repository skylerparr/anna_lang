package compiler;

import haxe.PosInfos;
import hscript.Macro;
import hscript.Parser;
import hscript.Interp;
import hscript.Printer;
using lang.AtomSupport;
using StringTools;

import haxe.macro.Expr;

@:build(lang.macros.ValueClassImpl.build())
class CppiaCompiler {
  @field public static var parser: Parser;
  @field public static var interp: Interp;
  @field public static var printer: Printer;
  @field public static var compilerCompleteCallbacks: Array<Dynamic>;

  public static function start(): Atom {
    if(printer == null) {
      printer = new Printer();
      parser = Native.callStaticField('Main', 'parser');
      interp = Native.callStaticField('Main', 'interp');
      compilerCompleteCallbacks = [];
      Native.callStaticField("Main", "compilerCompleteCallbacks").push(onCompilerComplete);
    }
    return 'ok'.atom();
  }

  public static function ast(code: String): Expr {
    var ast = parser.parseString(code);
    var pos = { max: 12, min: 0, file: null };
    return new Macro(pos).convert(ast);
  }

  public static function astToString(ast: Expr): String {
    var p: haxe.macro.Printer = new haxe.macro.Printer();
    return p.printExpr(ast);
  }

  public static function subscribeAfterCompile(clazz: String, func: String): Atom {
    compilerCompleteCallbacks.push({clazz: clazz, func: func});
    return 'ok'.atom();
  }

  public static function onCompilerComplete(): Void {
    for(cb in compilerCompleteCallbacks) {
      var cls: Class<Dynamic> = Type.resolveClass(cb.clazz);
      var fun = Reflect.field(cls, cb.func);
      Reflect.callMethod(null, fun, []);
    }
  }
}