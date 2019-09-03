package vm;

import EitherEnums.Either2;
import lang.EitherSupport;
class PutInScope implements Operation {

  private var value: Tuple;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function new(value: Tuple, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.value = value;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var argArray = value.asArray();
    var elem1: Either2<Atom, Dynamic> = argArray[0];
    var elem2: Either2<Atom, Dynamic> = argArray[1];
    switch(cast(EitherSupport.getValue(elem1), Atom)) {
      case {value: 'const'}:
        scopeVariables.set("$$$", EitherSupport.getValue(elem2));
      case {value: 'var'}:
        scopeVariables.set("$$$", scopeVariables.get(EitherSupport.getValue(elem2)));
    }
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}