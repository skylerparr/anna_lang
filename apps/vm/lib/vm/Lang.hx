package vm;
import lang.EitherSupport;
import lang.macros.MacroTools;
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

  public static var definedModules: Map<String, Dynamic> = {
    definedModules = new Map<String, Dynamic>();
    definedModules.set("Anna", Anna);
    definedModules.set("Atom", Atom);
    definedModules.set("Tuple", Tuple);
    definedModules.set("LList", LList);
    definedModules.set("MMap", MMap);
    definedModules.set("Keyword", Keyword);
    definedModules.set("Map", ObjectMap);
    definedModules.set("IO", IO);
    definedModules.set("EitherEnums", EitherEnums);
    definedModules.set("Std", Std);
    definedModules.set("ArgHelper", ArgHelper);
    definedModules.set("InterpMatch", InterpMatch);
    definedModules.set("vm", {Classes: vm.Classes, InterpMatch: vm.InterpMatch});
    definedModules.set("lang", {EitherSupport: EitherSupport});
    definedModules.set("A", function(v) {
      return v;
    });
    definedModules.set("B", function(v) {
      return v;
    });
    definedModules.set("C", function(v) {
      return v;
    });
    definedModules;
  };

  public inline static function eval(string:String):Tuple {
    string = StringTools.trim(string);
    string = StringTools.replace(string, "'", "\'");
    var isList: Bool = false;
    try {
      if(StringTools.startsWith(string, '{') && StringTools.endsWith(string, '}')) {
        isList = true;
      }
      var ast = parser.parseString(string);
      var pos = { max: 12, min: 0, file: null };
      var ast: Expr = new Macro(pos).convert(ast);
      invokeAst(ast, isList);
      return Tuple.create(['ok'.atom(), ast]);
    } catch(e: Dynamic) {
      trace(e);
      trace(CallStack.callStack().join(', '));
      return Tuple.create(['error'.atom(), '${e}']);
    }
  }

  public inline static function invokeAst(ast: Expr, isList: Bool): Atom {
    switch(ast.expr) {
        // handle defines here
      // ex: case "defCls":
      // ex: case "defType":
      // etc.
      case EBlock(exprs) if(!isList):
        var expr = MacroTools.buildBlock(exprs);
        invokeBlock(expr);
      case _:
        var expr = MacroTools.buildBlock([ast]);
        invokeBlock(expr);
    }
    return 'ok'.atom();
  }

  public static function getHaxeInterp(): Interp {
    var interp = new Interp();
    for(key in definedModules.keys()) {
      var value = definedModules.get(key);
      interp.variables.set(key, value);
    }
    return interp;
  }

  public static inline function resolveOperations(expr: Expr): Array<Operation> {
    AnnaLang.initCls();
    var exprs: Array<Expr> = AnnaLang.walkBlock(expr);
    var operations: Array<Operation> = [];
    for(expr in exprs) {
      var codeString = printer.printExpr(expr);
      codeString = StringTools.replace(codeString, 'null.push(', '');
      codeString = StringTools.replace(codeString, 'ops.push(', '');
      codeString = codeString.substr(0, codeString.length - 1);

      var ast = parser.parseString(codeString);
      var op: Operation = getHaxeInterp().execute(ast);
      operations.push(op);
    }
    return operations;
  }

  private static inline function invokeBlock(expr: Expr): Void {
    var operations = resolveOperations(expr);
    Process.apply(Process.self(), operations);
  }
}
