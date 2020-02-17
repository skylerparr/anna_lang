package vm;

import lang.macros.AnnaLang;
import ArgHelper;
class Assign implements Operation {
  public var arg: Tuple;
  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;
  public var annaLang: AnnaLang;

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }

  public inline function new(arg: Tuple, hostModule: Atom, hostFunction: Atom, lineNumber: Int, annaLang: AnnaLang) {
    this.arg = arg;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
    this.annaLang = annaLang;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var value: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables, annaLang);
    scopeVariables.set(value, scopeVariables.get("$$$"));
  }

  public function isRecursive(): Bool {
    return false;
  }
}