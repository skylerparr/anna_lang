package ;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class ArrayEnum {
  @:generic
  public static inline function reduce<T, K>(coll: Array<T>, iterator: Array<K>, fun: T->Array<K>->Array<K>): Array<K> {
    for(i in coll) {
      iterator = fun(i, iterator.copy());
    }
    return iterator;
  }

  @:generic
  public static inline function into<T, K>(coll: Array<T>, retVal: Array<K>, fun: T->K): Array<K> {
    for(i in coll) {
      var val: K = fun(i);
      retVal.push(val);
    }
    return retVal.copy();
  }

  @:generic
  public static inline function join<T>(coll: Array<T>, joiner: String): String {
    return coll.join(joiner);
  }
}
