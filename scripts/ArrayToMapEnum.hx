package;

class ArrayToMapEnum {
  @:generic
  public static inline function reduce<T, K, V>(coll: Array<T>, accumulator: Map<K, V>, fun: T->Map<K, V>->Map<K, V>): Map<K, V> {
    for(i in coll) {
      accumulator = fun(i, accumulator);
    }
    return accumulator;
  }
}