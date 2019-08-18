package vm;
import vm.Operation;
class DeclareAnonFunction implements Operation {

  public var func: Atom;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function new(func: Atom, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.func = func;

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    scopeVariables.set("$$$", func);
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}
