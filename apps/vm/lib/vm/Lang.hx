package vm;
import haxe.ds.ObjectMap;
import haxe.CallStack;
import hscript.Interp;
import lang.macros.MacroTools;
import lang.macros.AnnaLang;
import vm.Operation;
import haxe.macro.Printer;
import haxe.macro.Expr;
import hscript.Macro;
import hscript.Parser;
using lang.AtomSupport;
class Lang {

  private static var printer: Printer = new Printer();
  private static var parser: Parser = {
    var parser: Parser = new Parser();
    parser.allowMetadata = true;
    parser.allowTypes = true;
    parser;
  }

  public inline static function eval(string:String):Tuple {
    try {
      var ast = parser.parseString(string);
      var pos = { max: 12, min: 0, file: null };
      var ast: Expr = new Macro(pos).convert(ast);
      invokeAst(ast);
      return Tuple.create(['ok'.atom(), ast]);
    } catch(e: Dynamic) {
      trace(e);
      trace(CallStack.exceptionStack().join(', '));
      return Tuple.create(['error'.atom(), '${e}']);
    }
  }

  public inline static function invokeAst(ast: Expr): Atom {
    switch(ast.expr) {
      // handle defines here
      // ex: case "defCls":
      // ex: case "defType":
      // etc.
      case EBlock(_):
        invokeBlock(ast);
      case _:
        var expr = MacroTools.buildBlock([ast]);
        invokeBlock(expr);
    }
    return 'ok'.atom();
  }

  private static inline function invokeBlock(expr: Expr): Void {
    AnnaLang.initCls();
    var exprs: Array<Expr> = AnnaLang.walkBlock(expr);
    var operations: Array<Operation> = [];
    for(expr in exprs) {
      var codeString = printer.printExpr(expr);
      trace(codeString);
      codeString = StringTools.replace(codeString, 'null.push(', '');
      codeString = StringTools.replace(codeString, 'ops.push(', '');
      codeString = codeString.substr(0, codeString.length - 1);

      var ast = parser.parseString(codeString);
      var interp = new Interp();
      interp.variables.set("Atom", Atom);
      interp.variables.set("Tuple", Tuple);
      interp.variables.set("LList", LList);
      interp.variables.set("Keyword", Keyword);
      interp.variables.set("MMap", MMap);
      interp.variables.set("Map", ObjectMap);
      interp.variables.set("IO", IO);
      interp.variables.set("Repl", {});
      interp.variables.set("AnnaCompiler", {});
      interp.variables.set("EitherEnums", EitherEnums);
      interp.variables.set("SourceFile", SourceFile);
      interp.variables.set("ArgHelper", ArgHelper);
      interp.variables.set("A", function(v) {
        return v;
      });
      interp.variables.set("B", function(v) {
        return v;
      });
      var op: Operation = interp.execute(ast);
      operations.push(op);
    }

    Process.apply(Process.self(), operations);
  }
}
