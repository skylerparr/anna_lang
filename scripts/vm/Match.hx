package vm;

import EitherEnums.Either2;
import lang.EitherSupport;
class Match implements Operation {
  public var lhs: Tuple;
  public var rhs: Tuple;

  public var hostModule: Atom;

  public var hostFunction: Atom;

  public var lineNumber: Int;

  public function toString(): String {
    return "";
  }

  public inline function new(lhs: Tuple, rhs: Tuple) {
    this.lhs = lhs;
    this.rhs = rhs;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    var lElem0: Either2<Atom, Dynamic> = Tuple.elem(lhs, 0);
    var lElem1: Either2<Atom, Dynamic> = Tuple.elem(lhs, 1);
    var rElem0: Either2<Atom, Dynamic> = Tuple.elem(rhs, 0);
    var rElem1: Either2<Atom, Dynamic> = Tuple.elem(rhs, 1);
    switch(cast(EitherSupport.getValue(lElem0), Atom)) {
      case {value: 'const'}:
        throw "AnnaLang: Unsupported for now skyler";
      case {value: 'var'}:
        switch(cast(EitherSupport.getValue(rElem0), Atom)) {
          case {value: 'const'}:
            throw "AnnaLang: Unsupported for now skyler";
          case {value: 'var'}:
            scopeVariables.set(cast lElem1, scopeVariables.get(cast rElem1));
        }
    }
  }

  public function isRecursive(): Bool {
    return false;
  }
}