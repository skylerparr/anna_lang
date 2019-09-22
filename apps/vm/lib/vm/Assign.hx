package vm;

import util.ArgHelper;
import EitherEnums.Either2;
import lang.EitherSupport;
class Assign implements Operation {
  public var args: LList;
  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }

  public inline function new(args: LList, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.args = args;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    for(arg in LList.iterator(args)) {
      var value: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables);
      scopeVariables.set(value, scopeVariables.get("$$$"));
    }
  }

  public function isRecursive(): Bool {
    return false;
  }
}