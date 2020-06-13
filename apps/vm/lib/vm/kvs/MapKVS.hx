package vm.kvs;

import core.BaseObject;

class MapKVS implements KeyValueStore {

  private var kv: Map<String, Dynamic> = new Map<String, Dynamic>();

  public function new() {

  }

  public function init(): Void {

  }

  public function dispose(): Void {
    kv = null; 
  }

  public function store(key: String, value: Dynamic): Atom {
    kv.set(key, value);
    return Atom.create("ok");
  }

  public function fetch(key: String): Tuple {
    var value = kv.get(key);
    return Tuple.create([Atom.create("ok"), value]);
  }

  public function delete(key: String): Atom {
    kv.remove(key);
    return Atom.create("ok");
  }

  public function clear(): Atom {
    kv = new Map<String, Dynamic>();
    return Atom.create("ok");
  }
  
  public function getAndUpdate(key: String, newValue: Dynamic): Tuple {
    var retVal = fetch(key);
    store(key, newValue);
    return retVal;
  }

  public function getAndRemove(key: String): Tuple {
    var retVal = fetch(key);
    delete(key);
    return retVal;
  }

  public function exists(key: String): Atom {
    if(kv.exists(key)) {
      return Atom.create("true");
    } else {
      return Atom.create("false");
    }
  }
}
