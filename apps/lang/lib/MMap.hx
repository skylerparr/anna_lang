package ;

import lang.AbstractCustomType;
import haxe.ds.ObjectMap;
import haxe.CallStack;
import LList;
import haxe.ds.EnumValueMap;
import lang.AtomSupport;
import lang.CustomType;
import lang.EitherSupport;

using StringTools;

@:rtti
class MMap implements CustomType {

  public static function create(vals: Array<Any>): MMap {
    var map: AnnaMap<Any, Any> = new AnnaMap<Any, Any>();
    var key: Any = null;
    var value: Any = null;
    for(val in vals) {
      if(key == null) {
        key = val;
      } else if(value == null) {
        value = val;
      }
      if(key != null && value != null) {
        map._put(key, value);
        key = null;
        value = null;
      }
    }
    return map;
  }

  public static function get(map: MMap, key: Any, _default: Any = null): Any {
    var retVal: Any = (cast map)._get(key);
    if(retVal == null) {
      if(_default != null) {
        return _default;
      } else {
        return Atom.create("nil");
      }
    } else {
      return retVal;
    }
  }

  public static function put(map: MMap, key: Any, value: Any): Any {
    return (cast map)._put(key, value);
  }

  public static function remove(map: MMap, key: Any): MMap {
    return (cast map)._remove(key);
  }

  public static function hasKey(map: MMap, key: Any): Atom {
    return (cast map)._hasKey(key);
  }

  public static function keys(map: MMap): LList {
    return LList.create((cast map)._keys());
  }

  public static function haxeMap(map: MMap): Map<String, Dynamic> {
    return (cast map)._map;
  }

  public function toAnnaString(): String {
    return '';
  }
}

@:generic
class AnnaMap<K, V> extends MMap implements CustomType {

  public var _map: Map<String, V>;
  public var map: Map<String, K>;

  public var keyType: String;
  public var valueType: String;

  private var _annaString: String = null;

  public function new() {
    _map = new Map<String, V>();
    map = new Map<String, K>();

    keyType = '';
    valueType = '';
  }

  public function _put(key: K, value: V): AnnaMap<K, V> {
    var strKey: String = Anna.toAnnaString(key);
    _map.set(strKey, value);
    map.set(strKey, key);
    _annaString = null;
    return this;
  }

  public function _get(key: K): V {
    return _map.get(Anna.toAnnaString(key));
  }

  public function _remove(key: K): AnnaMap<K, V> {
    var strKey: String = Anna.toAnnaString(key);
    _map.remove(strKey);
    map.remove(strKey);
    _annaString = null;
    return this;
  }

  public function _hasKey(key: K): Atom {
    var strKey: String = Anna.toAnnaString(key);
    if(map.exists(strKey)) {
      return AtomSupport.atom('true');
    } else {
      return AtomSupport.atom('false');
    }
  }

  public function _keys(): Array<Any> {
    var retVal: Array<Any> = [];
    for(key in map) {
      retVal.push(key);
    }
    return retVal;
  }

  override public function toAnnaString(): String {
    if(_annaString == null) {
      var items: List<String> = new List<String>();
      var keys: Array<String> = [];
      for(value in map.keys()) {
        keys.push(value);
      }
      keys.sort(function(a:Dynamic, b:Dynamic):Int {
        a = EitherSupport.getValue(a);
        b = EitherSupport.getValue(b);
        if (a < b) return -1;
        if (a > b) return 1;
        return 0;
      });
      for(key in keys) {
        items.add('${key} => ${Anna.toAnnaString(_map.get(key))}');
      }

      _annaString = '%{${items.join(', ')}}';
    }
    return _annaString;
  }

}
