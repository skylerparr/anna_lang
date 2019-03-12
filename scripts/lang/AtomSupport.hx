package lang;

class AtomSupport {

  public static var atoms: HashTableAtoms = new HashTableAtoms();

  public inline static function atom(name: String): Atom {
    return atoms.get(name);
  }
}