package lang;
import lang.Types.Atom;
class HashTableAtoms implements Atoms {

  public static var NIL: Atom = {value: "nil", type: Types.ATOM};
  public static var TRUE: Atom = {value: "true", type: Types.ATOM};
  public static var FALSE: Atom = {value: "false", type: Types.ATOM};

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
      retVal = {value: name, type: Types.ATOM};
      atomMap.set(name, retVal);
    }
    return retVal;
  }
}