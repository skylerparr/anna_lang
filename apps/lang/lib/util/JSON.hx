package util;
import haxe.Json;
class JSON {
  public function new() {
  }

  public static inline function parse(str:String):Tuple {
    var obj: Dynamic = Json.parse(str);
    if(Std.is(obj, Array)) {
      var retVal: LList = DSUtil.dynamicArrayToList(obj);
      return Tuple.create([Atom.create('ok'), retVal]);
    } else {
      var retVal: MMap = DSUtil.dynamicToMap(obj);
      return Tuple.create([Atom.create('ok'), retVal]);
    }
  }

  public static inline function stringify(obj:Tuple):Tuple {
    var data: Dynamic = Tuple.elem(obj, 1);
    var retVal: String = null;
    if(Std.is(data, MMap)) {
      var toStringify: Dynamic = DSUtil.mmapToDynamic(data);
      retVal = Json.stringify(toStringify);
    } else {
      var toStringify: Dynamic = DSUtil.llistToDynamicArray(data);
      retVal = Json.stringify(toStringify);
    }
    if(retVal == null) {
      return Tuple.create([Atom.create('error'), 'Unable to parse object']);
    }
    return Tuple.create([Atom.create('ok'), retVal]);
  }
}
