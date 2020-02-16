package vm;
import lang.macros.MacroContext;
import hscript.plus.ParserPlus;
import hscript.Interp;
import hscript.Parser;
class InterpMatch implements Operation {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }
  public var code: String;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function new(code: String, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    //todo: store as ast and not a string for a performance boost
    this.code = code;

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    try {
      var ast = parser.parseString(code);
      var interp = Lang.getHaxeInterp();
      interp.variables.set("scopeVariables", scopeVariables);
      var matched: Map<String, Dynamic> = interp.execute(ast);
      if(Kernel.isNull(matched)) {
        IO.inspect('BadMatch: ${MacroContext.currentModule.name}.eval()');
        vm.Kernel.crash(vm.Process.self());
        return;
      }
      for(key in matched.keys()) {
        scopeVariables.set(key, matched.get(key));
      }
    } catch(e: Dynamic) {
      IO.inspect('BadMatch: ${MacroContext.currentModule.name}.eval() with error ${e}');
      vm.Kernel.crash(vm.Process.self());
    }
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}
