package lang;
class HashTableAtoms {

  public static var NIL: Atom = new Atom('nil');
  public static var TRUE: Atom = new Atom('true');
  public static var FALSE: Atom = new Atom('false');

  private var atomMap: Map<String, Atom>;

  private static var atoms: Map<String, Atom> = {
      var map = new Map<String, Atom>();
      map.set("nil", NIL);
      map.set("true", TRUE);
      map.set("false", FALSE);
      map;
  }

  public function new() {
    atomMap = new Map<String, Atom>();
  }

  public function getMap(): Map<String, Atom> {
    return atomMap;
  }

  public inline function get(name:String):Atom {
    var retVal: Atom = atomMap.get(name);
    if(retVal == null) {
      retVal = new Atom(name);
      atomMap.set(name, retVal);
    }
    return retVal;
  }
}