package vm;
import vm.SimpleFunction;
import vm.Operation;
using lang.AtomSupport;
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
    var varName: String = Atom.to_s(func);
    var frags = varName.split('.');
    var fun = frags.pop();
    var module = frags.join('.');
    var fn: Function = Classes.getFunction(module.atom(), fun.atom());
    if(fn == null) {
      IO.inspect('Anonymous function ${module} ${fun} not found.');
      Kernel.crash(Process.self());
      return;
    }
    var anonFn: Function = new SimpleFunction();
    anonFn.fn = fn.fn;
    anonFn.args = fn.args;
    anonFn.scope = scopeVariables;
    anonFn.apiFunc = hostFunction;

    scopeVariables.set("$$$", anonFn);
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}
