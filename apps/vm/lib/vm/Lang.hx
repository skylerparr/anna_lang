package vm;
import lang.EitherSupport;
import haxe.ds.ObjectMap;
import haxe.CallStack;
import hscript.Interp;
import lang.macros.AnnaLang;
import vm.Operation;
import haxe.macro.Printer;
import haxe.macro.Expr;
import hscript.Macro;
import vm.Port;
import vm.PortMan;
using lang.AtomSupport;
class Lang {

    public static var definedModules: Map<String, Dynamic> = {
    definedModules = new Map<String, Dynamic>();
    definedModules.set("Anna", Anna);
    definedModules.set("ArgHelper", ArgHelper);
    definedModules.set("Atom", Atom);
    definedModules.set("Code", Code);
    definedModules.set("EitherEnums", EitherEnums);
    definedModules.set("InterpMatch", InterpMatch);
    definedModules.set("IO", IO);
    definedModules.set("Keyword", Keyword);
    definedModules.set("LList", LList);
    definedModules.set("Map", ObjectMap);
    definedModules.set("MMap", MMap);
    definedModules.set("Port", SimplePort);
    definedModules.set("PortMan", PortMan);
    definedModules.set("Std", Std);
    definedModules.set("Tuple", Tuple);
    definedModules.set("vm", {
      Classes: vm.Classes,
      InterpMatch: vm.InterpMatch,
      Lang: vm.Lang,
      Process: vm.Process,
      InvokeNativeFunctionOperation: vm.InvokeNativeFunctionOperation
    });
    definedModules.set("lang", {
      EitherSupport: lang.EitherSupport,
      UserDefinedType: lang.UserDefinedType
    });
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

  public var annaLang: AnnaLang;
  private var printer: Printer;

  public function new() {
    annaLang = new AnnaLang();
    var code: Dynamic = Type.resolveClass("Code");
    annaLang.macroContext = code.annaLang.macroContext.clone();
    annaLang.lang = this;
    printer = annaLang.printer;
  }

  public function doEval(string: String): Tuple {
    string = StringTools.trim(string);
    string = StringTools.replace(string, "'", "\'");
    var isList: Bool = false;
    try {
      if(StringTools.startsWith(string, '{') && StringTools.endsWith(string, '}')) {
        isList = true;
      }
      var ast = annaLang.parser.parseString(string);
      var pos = { max: 12, min: 0, file: null };
      var ast: Expr = new Macro(pos).convert(ast);
      invokeAst(ast, isList);
      return Tuple.create(['ok'.atom(), ast]);
    } catch(e: Dynamic) {
      if(StringTools.endsWith(e, '"<eof>"')) {
        return Tuple.create(['ok'.atom(), 'continuation'.atom()]);
      } else {
        trace(e);
        trace("call stack:", CallStack.callStack().join('\n'));
        trace("exception stack:", CallStack.exceptionStack().join('\n'));
        return Tuple.create(['error'.atom(), '${e}']);
      }
    }
  }

  public inline static function eval(string:String):Tuple {
    var lang: Lang = new Lang();
    return lang.doEval(string);
  }

  public inline function invokeAst(ast: Expr, isList: Bool): Atom {
    switch(ast.expr) {
      // handle defines here
      // ex: case "defCls":
      // ex: case "defType":
      // etc.
      case EBlock(exprs) if(!isList):
        var expr = annaLang.macroTools.buildBlock(exprs);
        invokeBlock(expr);
      case _:
        var expr = annaLang.macroTools.buildBlock([ast]);
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

  public inline function resolveOperations(expr: Expr): Array<Operation> {
    var exprs: Array<Expr> = annaLang.walkBlock(expr);
    return parseOperations(exprs);
  }

  public function parseOperations(exprs: Array<Expr>): Array<Operation> {
    var operations: Array<Operation> = [];
    for(expr in exprs) {
      var codeString = printer.printExpr(expr);
      codeString = StringTools.replace(codeString, 'null.push(', '');
      codeString = StringTools.replace(codeString, 'ops.push(', '');
      codeString = codeString.substr(0, codeString.length - 1);

      var ast = annaLang.parser.parseString(codeString);
      var op: Operation = getHaxeInterp().execute(ast);
      operations.push(op);
    }
    return operations;
  }

  private inline function invokeBlock(expr: Expr): Void {
    var operations = resolveOperations(expr);
    var op: InterpretedOperation = new InterpretedOperation(
      Atom.create('__DefaultType__'),
      Atom.create('__default__'),
      1,
      annaLang
    );
    operations.push(op);
    var scope: Map<String, Dynamic> = MMap.haxeMap(Process.self().dictionary);
    for(key in scope.keys()) {
      var varKey = StringTools.replace(key, '"', '');
      Process.self().processStack.getVariablesInScope().set(varKey, scope.get(key));
    }
    Process.apply(Process.self(), operations);
  }
}
