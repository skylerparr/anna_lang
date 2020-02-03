package vm;
class InvokeAnonFunction implements Operation {
  public var fun: Function;
  public var args: LList;

  public var hostModule:Atom;
  public var hostFunction:Atom;
  public var lineNumber:Int;

  public function new(fun: Function, args: LList, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.fun = fun;
    this.args = args;

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables:Map<String,Dynamic>, processStack:ProcessStack):Void {
    Kernel.apply(Process.self(), fun, args);
  }

  public function isRecursive():Bool {
    return false;
  }

  public function toString():String {
    return "Invoke anonymous function";
  }

}
