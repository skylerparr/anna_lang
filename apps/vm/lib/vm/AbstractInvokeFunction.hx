package vm;

import lang.macros.AnnaLang;
import lang.macros.MacroContext;
import haxe.macro.Expr.TypeDefinition;
class AbstractInvokeFunction implements Operation {

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;
  public var annaLang: AnnaLang;

  public inline function new(hostModule: Atom, hostFunction: Atom, lineNumber: Int, annaLang: AnnaLang) {
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
    this.annaLang = annaLang;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    throw "This must be overridden";
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString() {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}