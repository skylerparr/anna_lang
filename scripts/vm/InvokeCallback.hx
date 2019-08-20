package vm;
class InvokeCallback implements Operation {
  private var callback: Dynamic->Void;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function new(callback: Dynamic->Void, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.callback = callback;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    callback(scopeVariables.get("$$$"));
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return "Anonymous callback";
  }
}
