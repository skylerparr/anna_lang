package lang;

using lang.AtomSupport;
import haxe.ds.ObjectMap;
class MapUtil {
  public static function toMap(obj: Dynamic): ObjectMap<Dynamic, Dynamic> {
    var retVal: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    for(f in Reflect.fields(obj)) {
      retVal.set(f, Reflect.field(obj, f));
    }
    return retVal;
  }

  public static function toDynamic(obj: ObjectMap<Dynamic, Dynamic>): Dynamic {
    var retVal: Dynamic = {};
    var kv: Array<Dynamic> = [];
    for(key in obj.keys()) {
      var val = obj.get(key);
      kv.push({key: key, val: val});
    }
    for(vals in kv) {
      switch(vals.val) {
        case [name, _, _]:
          Reflect.setField(retVal, vals.key, name);
        case _:
          Reflect.setField(retVal, vals.key, vals.val);
      }
    }
    return retVal;
  }
}