package vm;
import hscript.Expr;
import lang.macros.AnnaLang;
import lang.macros.MacroContext;
import hscript.plus.ParserPlus;
import hscript.Interp;
import hscript.Parser;
class InterpMatch implements Operation {
  public var code: String;
  private var ast: Expr;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;
  public var annaLang: AnnaLang;

  public function new(code: String, hostModule: Atom, hostFunction: Atom, lineNumber: Int, annaLang: AnnaLang) {
    this.code = code;
    ast = annaLang.parser.parseString(code);

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
    this.annaLang = annaLang;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    try {
      var interp = Lang.getHaxeInterp();
      interp.variables.set("scopeVariables", scopeVariables);
      var matched: Map<String, Dynamic> = interp.execute(ast);
      if(NativeKernel.isNull(matched)) {
        IO.inspect('BadMatch: ${annaLang.macroContext.currentModule.name}.eval()');
        vm.NativeKernel.crash(vm.Process.self());
        return;
      }
      for(key in matched.keys()) {
        scopeVariables.set(key, matched.get(key));
      }
    } catch(e: Dynamic) {
      IO.inspect('BadMatch: ${annaLang.macroContext.currentModule.name}.eval() with error ${e}');
      vm.NativeKernel.crash(vm.Process.self());
    }
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}
