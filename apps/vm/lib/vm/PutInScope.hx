package vm;

import EitherEnums.Either1;
import util.ArgHelper;
import util.ArgHelper;
import EitherEnums.Either2;
import lang.EitherSupport;
class PutInScope implements Operation {

  private var value: Tuple;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function new(value: Tuple, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.value = value;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    scopeVariables.set("$$$", ArgHelper.extractArgValue(A(value), scopeVariables));
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}