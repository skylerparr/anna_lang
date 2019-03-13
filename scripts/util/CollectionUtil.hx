package util;

import lang.AtomSupport;
import lang.ModuleSpec;
import lang.FunctionSpec;
import haxe.ds.ObjectMap;
using lang.AtomSupport;

class CollectionUtil {

  public static function getSampleList(): Dynamic {
    return lang.CustomTypes.createList("String", ['foo','bar']);
  }

  public static function getSampleMap(): Dynamic {
    return lang.CustomTypes.createMap("lang.ModuleSpec", "lang.FunctionSpec", cast [ new ModuleSpec(AtomSupport.atom("nil"), [], AtomSupport.atom("nil"), AtomSupport.atom("nil")) => new lang.FunctionSpec(AtomSupport.atom("nil"), "", [[]], AtomSupport.atom("nil"), []) ]);
  }

  public static function fillList(list: Dynamic, items: Array<Any>): Void {
    items.reverse();
    for(i in items) {
      list.push(i);
    }
  }

  public static function fillMap(map: Dynamic, items: Map<Any, Any>): Void {
    for(key in items.keys()) {
      map.put(key, items.get(key));
    }
  }
}