package;

import lang.EitherSupport;
import haxe.ds.EnumValueMap;
import haxe.Json;
import EitherEnums.Either1;
import haxe.ds.ObjectMap;
import lang.CustomTypes.CustomType;

using StringTools;

class MMap implements CustomType {

  public static function create(vals: EnumValueMap<Dynamic, Dynamic>): MMap {
    var map: AnnaMap<Any, Any> = new AnnaMap<Any, Any>();
    for(k in vals.keys()) {
      map._put(k, vals.get(k));
    }
    return map;
  }

  public static function get(map: MMap, key: Any): Any {
    return (cast map)._get(key);
  }

  public static function put(map: MMap, key: Any, value: Any): Any {
    return (cast map)._put(key, value);
  }

  public static function remove(map: MMap, key: Any): Any {
    return (cast map)._remove(key, key);
  }

  public function toAnnaString(): String {
    return '';
  }

  public function toHaxeString(): String {
    return '';
  }

  public function toPattern(patternArgs: Array<KeyValue<String,String>> = null): String {
    return '';
  }
}

@:generic
class AnnaMap<K, V> extends MMap implements CustomType {

  public var _map: Map<String, V>;
  public var map: Map<String, K>;

  public var keyType: String;
  public var valueType: String;

  public function new() {
    _map = new Map<String, V>();
    map = new Map<String, K>();

    var keyTypeSet: Bool = false;

    keyType = '';
    valueType = '';
  }

  public function _put(key: K, value: V): AnnaMap<K, V> {
    var strKey: String = Anna.toAnnaString(key);
    _map.set(strKey, value);
    map.set(strKey, key);
    return this;
  }

  public function _get(key: K): V {
    return _map.get(Anna.toAnnaString(key));
  }

  public function _remove(key: K): AnnaMap<K, V> {
    var strKey: String = Anna.toAnnaString(key);
    _map.remove(strKey);
    map.remove(strKey);
    return this;
  }

  override public function toAnnaString(): String {
    var items: Array<String> = [];
    var keys: Array<String> = [];
    for(value in map.keys()) {
      keys.push(value);
    }
    keys.sort(function(a:Dynamic, b:Dynamic):Int {
      a = EitherSupport.getValue(a);
      b = EitherSupport.getValue(b);
      if (a.toLowerCase() < b.toLowerCase()) return -1;
      if (a.toLowerCase() > b.toLowerCase()) return 1;
      return 0;
    });
    for(key in keys) {
      items.push('${key} => ${Anna.toAnnaString(_map.get(key))}');
    }

    return '%{${items.join(', ')}}';
  }

  override public function toHaxeString(): String {
    var mapArgs: Array<String> = [];
    for(key in map.keys()) {
      mapArgs.push('${Anna.toHaxeString(key)} => ${Anna.toHaxeString(map.get(key))}');
    }
    return 'lang.CustomTypes.createMap("${keyType}", "${valueType}", cast [ ${mapArgs.join(', ')} ])';
  }

  override public function toPattern(patternArgs: Array<KeyValue<String,String>> = null): String {
    return '';
  }

  public function toString(): String {
    return 'Map';
  }
}