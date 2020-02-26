package vm;
import lang.macros.AnnaLang;
class InterpretedOperation implements Operation {

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;
  public var annaLang: AnnaLang;

  public function new(hostModule: Atom, hostFunction: Atom, lineNumber: Int, annaLang: AnnaLang) {
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
    this.annaLang = annaLang;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var currentPid: Pid = Process.self();
    for(key in scopeVariables.keys()) {
      if(key == "$$$" || key == "text") {
        continue;
      }
      var dictionary = currentPid.dictionary;
      MMap.put(dictionary, key, scopeVariables.get(key));
    }
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}
