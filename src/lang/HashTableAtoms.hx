package lang;
class HashTableAtoms {

  public static var atoms: Map<String, Atom> = new Map<String, Atom>();

  public static function count(): Int {
    var count: Int = 0;
    for(i in atoms) {
      count++;
    }
    return count;
  }

  public static inline function get(name:String):Atom {
    var retVal: Atom = atoms.get(name);
    if(retVal == null) {
      retVal = new Atom(name);
      atoms.set(name, retVal);
    }
    return retVal;
  }
}