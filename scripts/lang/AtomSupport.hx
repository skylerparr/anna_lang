package lang;

class AtomSupport {

  public inline static function atom(name: String): Atom {
    return HashTableAtoms.get(name);
  }
}