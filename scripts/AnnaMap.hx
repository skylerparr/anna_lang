package;

import util.StringUtil;
import haxe.ds.ObjectMap;
import lang.CustomTypes.CustomType;

using StringTools;

@:generic
class AnnaMap<K, V> implements CustomType {

  public var _map: Map<String, V>;
  public var map: ObjectMap<Dynamic, V>;

  public var keyType: String;
  public var valueType: String;

  public function new() {
    _map = new Map<String, V>();
    map = new ObjectMap<Dynamic, V>();

    var keyTypeSet: Bool = false;

    keyType = '';
    valueType = '';

    switch(Type.typeof(this)) {
      case TClass(clazz):
        var classString: String = '${clazz}';
        var types = classString.replace('AnnaMap_', '');
        var frags: Array<String> = types.split('_');
        for(frag in frags) {
          if(!keyTypeSet) {
            if(StringUtil.CAPITALS.match(frag.charAt(0))) {
              keyType += frag;
              keyTypeSet = true;
            } else {
              keyType += '${frag}.';
            }
          } else {
            if(StringUtil.CAPITALS.match(frag.charAt(0))) {
              valueType += frag;
            } else {
              valueType += '${frag}.';
            }
          }
        }
      case _:

    }
  }

  public function put(key: K, value: V): AnnaMap<K, V> {
    _map.set(Anna.toAnnaString(key), value);
    map.set(key, value);
    return this;
  }

  public function get(key: K): V {
    return _map.get(Anna.toAnnaString(key));
  }

  public function remove(key: K): AnnaMap<K, V> {
    _map.remove(Anna.toAnnaString(key));
    map.remove(key);
    return this;
  }

  public function toAnnaString(): String {
    var items: Array<String> = [];
    var keys: Array<Dynamic> = [];
    for(key in map.keys()) {
      keys.push(key);
    }
    keys.sort( function(a:Dynamic, b:Dynamic):Int {
      if(Std.is(a, Atom) && Std.is(b, Atom)) {
        if (a.value < b.value) return -1;
        if (a.value > b.value) return 1;
      } else if(Std.is(a, String) && Std.is(b, String)) {
        if (a.toLowerCase() < b.toLowerCase()) return -1;
        if (a.toLowerCase() > b.toLowerCase()) return 1;
      } else {
        if (a < b) return -1;
        if (a > b) return 1;
      }
      return 0;
    });
    for(key in keys) {
      items.push('${Anna.toAnnaString(key)} => ${Anna.toAnnaString(map.get(key))}');
    }

    return '%{${items.join(', ')}}';
  }

  public function toHaxeString(): String {
    var mapArgs: Array<String> = [];
    for(key in map.keys()) {
      mapArgs.push('${Anna.toHaxeString(key)} => ${Anna.toHaxeString(map.get(key))}');
    }
    return 'lang.CustomTypes.createMap("${keyType}", "${valueType}", cast [ ${mapArgs.join(', ')} ])';
  }

  public function toPattern(patternArgs: Array<KeyValue<String,String>> = null): String {
    return '';
  }

  public function toString(): String {
    return 'Map';
  }
}