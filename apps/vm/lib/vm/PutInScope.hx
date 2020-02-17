package vm;

import lang.macros.AnnaLang;
import EitherEnums.Either1;
import ArgHelper;
import ArgHelper;
import EitherEnums.Either2;
import lang.EitherSupport;
class PutInScope implements Operation {

  private var value: Tuple;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;
  public var annaLang: AnnaLang;

  public function new(value: Tuple, hostModule: Atom, hostFunction: Atom, lineNumber: Int, annaLang: AnnaLang) {
    this.value = value;

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
    this.annaLang = annaLang;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    scopeVariables.set("$$$", ArgHelper.extractArgValue(value, scopeVariables, annaLang));
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}