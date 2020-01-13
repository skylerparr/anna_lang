package vm;

import ArgHelper;
class Assign implements Operation {
  public var arg: Tuple;
  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }

  public inline function new(arg: Tuple, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.arg = arg;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var value: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables);
    scopeVariables.set(value, scopeVariables.get("$$$"));
  }

  public function isRecursive(): Bool {
    return false;
  }
}