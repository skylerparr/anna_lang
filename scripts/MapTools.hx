package;

using lang.AtomSupport;

class MapTools {

  @:generic
  public static inline function put<K, V>(map: Map<K, V>, key: K, value: V): Map<K, V> {
    map.set(key, value);
    return map;
  }

  @:generic
  public static inline function get<K, V>(map: Map<K, V>, key: K, _default: Dynamic): V {
    var retVal: V = map.get(key);
    if(retVal == null) {
      retVal = _default;
    }
    return retVal;
  }

}