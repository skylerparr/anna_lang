package vm;

class AbstractInvokeFunction implements Operation {
  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public inline function new(hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
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