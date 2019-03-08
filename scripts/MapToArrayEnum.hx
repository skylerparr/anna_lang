package;

class MapToArrayEnum {
  @:generic
  public static inline function reduce<K, V, T>(map: Map<K, V>, accumulator: Array<T>, fun: KeyValue<K, V>->Array<T>->Array<T>): Array<T> {
    for(i in map.keys()) {
      var kv: KeyValue<K, V> = new KeyValue<K, V>(i, map.get(i));
      accumulator = fun(kv, accumulator);
    }
    return accumulator;
  }

  @:generic
  public static inline function into<K, V, T>(map: Map<K, V>, iterator: Array<T>, fun: KeyValue<K, V>->T): Array<T> {
    for(i in map.keys()) {
      var kv: KeyValue<K, V> = new KeyValue<K, V>(i, map.get(i));
      var val: T = fun(kv);
      iterator.push(val);
    }
    return iterator;
  }
}