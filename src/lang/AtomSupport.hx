package lang;

import lang.Types.Atom;
class AtomSupport {

  public static var atoms: Atoms;

  public inline static function atom(name: String): Atom {
    return atoms.get(name);
  }
}