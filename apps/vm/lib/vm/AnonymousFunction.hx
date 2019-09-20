package vm;
import vm.Function;
using lang.AtomSupport;
class AnonymousFunction implements Operation {
  public var func: Atom;
  public var args: LList;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function new(func: Atom, args: LList, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.func = func;
    this.args = args;

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var funVar: Atom = scopeVariables.get(Atom.to_s(func));
    if(funVar == null) {
      Logger.inspect("Anonymous function not found");
      return;
    }
    var frags = Atom.to_s(funVar).split('.');
    var fun = frags.pop();
    var module = frags.join('.');
    var fn: Function = Classes.getFunction(module.atom(), fun.atom());
    if(fn == null) {
      Logger.inspect("Anonymous function not found");
      return;
    }
    Kernel.apply(Process.self(), fn, args);
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}
