package util;

import haxe.ds.ObjectMap;
class UniqueList<T> {
  private var array: Array<T>;
  private var map: ObjectMap<Dynamic, T>;

  public function new() {
    array = [];
    map = new ObjectMap<Dynamic, T>();
  }

  public function asArray(): Array<T> {
    return array;
  }

  public function push(item: T): T {
    if(map.exists(item)) {
      return item;
    }
    map.set(item, item);
    array.push(item);
    return item;
  }

  public function add(item: T): T {
    if(map.exists(item)) {
      return item;
    }
    map.set(item, item);
    array.unshift(item);
    return item;
  }

  public function first(): T {
    return array[0];
  }

  public function pop(): T {
    var item: T = array.pop();
    map.remove(item);
    return item;
  }

  public function shift(): T {
    var item: T = array.shift();
    map.remove(item);
    return item;
  }

  public function remove(item: T): Bool {
    array.remove(item);
    return map.remove(item);
  }

  public function length(): Int {
    return array.length;
  }

  public function iterator(): Iterator<T> {
    return array.iterator();
  }
}