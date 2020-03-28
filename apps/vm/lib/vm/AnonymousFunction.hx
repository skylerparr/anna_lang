package vm;
import lang.macros.AnnaLang;
import vm.Function;
using lang.AtomSupport;
class AnonymousFunction implements Operation {
  public var func: Atom;
  public var args: LList;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;
  public var annaLang: AnnaLang;

  public function new(func: Atom, args: LList, hostModule: Atom, hostFunction: Atom, lineNumber: Int, annaLang: AnnaLang) {
    this.func = func;
    this.args = args;

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
    this.annaLang = annaLang;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var varName: String = Atom.to_s(func);
    var fn: Function = scopeVariables.get(varName);
    if(fn == null) {
      IO.inspect('AnonymousFunction: Function not found ${func.toAnnaString()} ${Anna.toAnnaString(args)}:${lineNumber}');
      NativeKernel.crash(Process.self());
      return;
    }
    NativeKernel.apply(Process.self(), fn, args);
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}
