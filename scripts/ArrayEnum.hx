package ;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class ArrayEnum {
  @:generic
  public static inline function reduce<T, K>(coll: Array<T>, iterator: Array<K>, fun: T->Array<K>->Array<K>): Array<K> {
    for(i in coll) {
      iterator = fun(i, iterator);
    }
    return iterator.copy();
  }

  @:generic
  public static inline function into<T, K>(coll: Array<T>, iterator: Array<K>, fun: T->K): Array<K> {
    for(i in coll) {
      var val: K = fun(i);
      iterator.push(val);
    }
    return iterator.copy();
  }

  @:generic
  public static inline function with_index<T>(coll: Array<T>): Array<Array<Dynamic>> {
    var retVal: Array<Array<Dynamic>> = new Array<Array<Dynamic>>();
    var index: Int = 0;
    for(i in coll) {
      retVal.push([i, index++]);
    }
    return retVal;
  }

  @:generic
  public static inline function join<T>(coll: Array<T>, joiner: String): String {
    return coll.join(joiner);
  }

  @:generic
  public static inline function find<T>(coll: Array<T>, fun: T -> Bool): T {
    var retVal: T = null;
    for(i in coll) {
      if(fun(i)) {
        retVal = i;
        break;
      }
    }
    return retVal;
  }

  @:generic
  public static function filter<T>(coll: Array<T>, fun: T -> Bool): Array<T> {
    return coll.filter(fun);
  }
}
