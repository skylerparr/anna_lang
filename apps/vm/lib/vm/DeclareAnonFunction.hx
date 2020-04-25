package vm;
import lang.macros.AnnaLang;
import vm.SimpleFunction;
import vm.Operation;
using lang.AtomSupport;
class DeclareAnonFunction implements Operation {

  public var func: Atom;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;
  public var annaLang: AnnaLang;

  public function new(func: Atom, hostModule: Atom, hostFunction: Atom, lineNumber: Int, annaLang: AnnaLang) {
    this.func = func;

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
    this.annaLang = annaLang;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var varName: String = Atom.to_s(func);
    var frags = varName.split('.');
    var fun = frags.pop();
    var module = frags.join('.');

    var anonFn: AnonFn = new AnonFn();
    anonFn.module = module.atom();
    anonFn.func = fun;
    anonFn.args = [];
    anonFn.annaLang = annaLang;
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
