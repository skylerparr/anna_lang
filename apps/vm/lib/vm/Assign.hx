package vm;

import EitherEnums.Either2;
import lang.EitherSupport;
class Assign implements Operation {
  public var args: LList;
  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }

  public inline function new(args: LList, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.args = args;
    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    for(arg in LList.iterator(args)) {
      var tuple: Tuple = EitherSupport.getValue(arg);
      var argArray = tuple.asArray();
      var elem1: Either2<Atom, Dynamic> = argArray[0];
      var elem2: Either2<Atom, Dynamic> = argArray[1];
      switch(cast(EitherSupport.getValue(elem1), Atom)) {
        case {value: 'const'}:
          scopeVariables.set(EitherSupport.getValue(elem2), scopeVariables.get("$$$"));
      }
    }
  }

  public function isRecursive(): Bool {
    return false;
  }
}