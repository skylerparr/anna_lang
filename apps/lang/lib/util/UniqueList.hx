package util;

import haxe.ds.ObjectMap;
class UniqueList<T> {
  private var list: List<T>;
  private var map: ObjectMap<Dynamic, T>;

  public function new() {
    list = new List<T>();
    map = new ObjectMap<Dynamic, T>();
  }

  public function push(item: T): T {
    if(map.exists(item)) {
      return item;
    }
    map.set(item, item);
    list.push(item);
    return item;
  }

  public function add(item: T): T {
    if(map.exists(item)) {
      return item;
    }
    map.set(item, item);
    list.add(item);
    return item;
  }

  public function first(): T {
    return list.first();
  }

  public function pop(): T {
    var item: T = list.pop();
    map.remove(item);
    return item;
  }

  public function unshift(): T {
    var item: T = list.first();
    list.remove(item);
    map.remove(item);
    return item;
  }

  public function length(): Int {
    return list.length;
  }

}