package vm;
import lang.FunctionClauseNotFound;
import lang.ParsingException;
import util.StringUtil;
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
import Tuple.TupleInstance;
import haxe.CallStack;
import haxe.rtti.CType.Classdef;
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
    definedModules.set("Perf", Perf);
    definedModules.set("Port", SimplePort);
    definedModules.set("PortMan", PortMan);
    definedModules.set("Std", Std);
    definedModules.set("Sys", Sys);
    definedModules.set("sys", {FileSystem: sys.FileSystem});
    definedModules.set("sys.io", {File: sys.io.File});
    definedModules.set("Tuple", Tuple);
    definedModules.set("util", {
      AST: util.AST,
      Compiler: util.Compiler,
      JSON: util.JSON,
      File: util.File,
      StringUtil: util.StringUtil,
      Template: util.Template,
    });
    definedModules.set("vm", {
      Classes: vm.Classes,
      InterpMatch: vm.InterpMatch,
      Lang: vm.Lang,
      NativeKernel: vm.NativeKernel,
      Process: vm.Process,
      InvokeNativeFunctionOperation: vm.InvokeNativeFunctionOperation,
      DeclareAnonFunction: vm.DeclareAnonFunction,
      AnonymousFunction: vm.AnonymousFunction,
      PortMan: vm.PortMan,
      KVSApi: vm.KVSApi,
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
  private var evals: Array<Dynamic> = [];
  private var ref: Reference;

  private static inline var ANNA_HOME: String = 'ANNA_HOME';
  private static var transactionMap: ObjectMap<Reference, Lang> = new ObjectMap<Reference, Lang>();

  public static function annaLangHome(): String {
    var annaLangHome: String = Sys.environment().get(ANNA_HOME);
    if(annaLangHome == null) {
      annaLangHome = '';
    }
    return annaLangHome;
  }

  public function new() {
    annaLang = new AnnaLang();
    var code: Dynamic = Type.resolveClass("Code");
    annaLang.updateMacroContext(code.annaLang.macroContext.clone());
    annaLang.lang = this;
    printer = annaLang.printer;
    ref = new Reference();
  }

  public function doEval(string: String): Tuple {
    string = StringUtil.removeWhitespace(string);
    string = StringTools.trim(string);
    string = StringTools.replace(string, "'", "\'");
    var isList: Bool = false;
    if(StringTools.startsWith(string, '{') && StringTools.endsWith(string, '}')) {
      isList = true;
    }
    var ast: Dynamic = null;

    try {
      ast = annaLang.parser.parseString(string);
    } catch(pe: ParsingException) {
      trace(pe.message);
      return Tuple.create([Atom.create('error'), '${pe.message}']);
    } catch(e: Dynamic) {
      if(StringTools.endsWith(e, '"<eof>"')) {
        return Tuple.create([Atom.create('ok'), Atom.create('continuation')]);
      } else if(StringTools.endsWith(e, 'Unterminated string')) {
        return Tuple.create([Atom.create('ok'), Atom.create('continuation')]);
      } else {
        trace(e);
        return Tuple.create([Atom.create('error'), '${e}']);
      }
    }

    try {
      var pos = { max: ast.pmax, min: ast.pmin, file: 'none:${ast.line}' };
      ast = new Macro(pos).convert(ast);
    } catch(e: Dynamic) {
      return Tuple.create([Atom.create('error'), '${e}']);
    }
    evals.push({ast: ast, isList: isList});
    return Tuple.create([Atom.create('ok'), ast]);
  }

  public static inline function eval(string:String):Tuple {
    var ref: Reference = beginTransaction();
    var lang: Lang = transactionMap.get(ref);

    var result: Tuple = lang.doEval(string);
    if(Tuple.elem(result, 0) == Atom.create('ok') && Tuple.elem(result, 1) != Atom.create('continuation')) {
      return commit(ref);
    } else {
      return result;
    }
  }

  public static inline function disposeTransaction(ref: Reference): Tuple {
    transactionMap.remove(ref);
    return Tuple.create([Atom.create('ok'), 'disposed']); 
  }

  public static inline function read(ref: Reference, string: String): Tuple {
    var lang: Lang = transactionMap.get(ref);
    return lang.doEval(string);
  }

  public static inline function beginTransaction(): Reference {
    var lang: Lang = new Lang();
    var ref = lang.ref;
    transactionMap.set(ref, lang);
    return ref;
  }

  public static inline function commit(ref: Reference): Tuple {
    var lang: Lang = transactionMap.get(ref);
    if(lang == null) {
      return Tuple.create([Atom.create('error'), 'transaction not found']);
    }
    return lang.doCommit();
  }

  public function doCommit(): Tuple {
    try {
      for(eval in evals) {
        invokeAst(eval.ast, eval.isList);
      }
      annaLang.commit();
      disposeTransaction(ref);
      return Tuple.create([Atom.create('ok'), 'success']);
    } catch(e: ParsingException) {
      trace(e);
      return Tuple.create([Atom.create('error'), '${e}']);
    } catch(e: FunctionClauseNotFound) {
      trace(e);
      return Tuple.create([Atom.create('error'), 'FunctionClauseNotFound: ${e}']);
    } catch(e: lang.MissingApiFunctionException) {
      trace(e.message);
      return Tuple.create([Atom.create('error'), 'MissingApiFunction: ${e.message}']);
    } catch(e: Dynamic) {
      trace("call stack:", CallStack.callStack().join('\n'));
      trace("exception stack:", CallStack.exceptionStack().join('\n'));
      trace("TODO: Handle this exception");
      trace(e);
      return Tuple.create([Atom.create('error'), '${e}']);
    }
  }

  public static inline function format(string: String): Tuple {
    var lang: Lang = new Lang();
    return lang.doFormat(string);
  }

  public function doFormat(string: String): Tuple {
    var ast: Dynamic = null; 
    try {
      ast = annaLang.parser.parseString(string);
      var pos = { max: ast.pmax, min: ast.pmin, file: ':${ast.line}' };
      ast = new Macro(pos).convert(ast);
    } catch(pe: ParsingException) {
      return Tuple.create([Atom.create('error'), '${pe.message}']);
    } catch(e: Dynamic) {
      return Tuple.create([Atom.create('error'), '${e}']);
    }
    var formatted: String = printer.printExpr(ast);
    formatted = StringTools.replace(formatted, "\"", "'");
    formatted = StringTools.replace(formatted, "@_ ", "@_");
    formatted = StringTools.replace(formatted, "\t", "  ");
    formatted = StringTools.replace(formatted, "  @def", "\n  @def");
    var regex: EReg = ~/({.[A-Z]*.*}|{*{.*?:|,.*:)/g;
    formatted = regex.map(formatted, function(e: EReg): String {
      var matched: String = e.matched(0);
      matched = StringTools.replace(matched, "{ ", "{");
      matched = StringTools.replace(matched, " :", ":");
      matched = StringTools.replace(matched, " }", "}");
      return matched;
    });
    regex = ~/([A-Z][a-z]*\s%\s)/g;
    formatted = regex.map(formatted, function(e) {
      var matched: String = e.matched(0);
      matched = StringTools.replace(matched, " % ", "%");
      return matched;
    });
    if(StringTools.startsWith(formatted, "{")) {
      formatted = ~/{\s*/.replace(formatted, ""); 
      formatted = formatted.substring(0, formatted.length - 2); 
      formatted = ~/\n\s*/g.replace(formatted, "\n");
    }

    return Tuple.create([Atom.create('ok'), formatted]);
  }

  public inline function invokeAst(ast: Expr, isList: Bool): Atom {
    annaLang.macroContext.currentPosition = ast.pos;
    switch(ast.expr) {
      case EBlock(exprs) if(!isList):
        var expr = annaLang.macroTools.buildBlock(exprs);
        invokeBlock(expr);
      case _:
        var expr = annaLang.macroTools.buildBlock([ast]);
        invokeBlock(expr);
    }
    return Atom.create('ok');
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
      Atom.create('__DefaultModule__'),
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
