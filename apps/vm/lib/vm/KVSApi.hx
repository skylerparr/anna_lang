package vm;

import vm.*;
import vm.kvs.*;

@:rtti
class KVSApi {
  private static var stores: Map<Reference, KeyValueStore> = new Map<Reference, KeyValueStore>();

  public static inline var TYPE_READ_CONCURRENT: String = "read_concurrent";
  public static inline var TYPE_READ_CONCURRENT_PROTECTED: String = "read_concurrent_protected";
  public static inline var TYPE_UNSAFE: String = "unsafe";

  public static function create(type: Atom): Tuple {
    var kvs: KeyValueStore = null;
    if(type == Atom.create(TYPE_READ_CONCURRENT)) {
#if cpp
      kvs = new CPPReadConcurrentKVS();  
#end
    } else if(type == Atom.create(TYPE_READ_CONCURRENT_PROTECTED)) {
      
    } else if(type == Atom.create(TYPE_UNSAFE)) {
      kvs = new MapKVS();  
    } 
    return register(kvs);
  }

  private static inline function register(kvs: KeyValueStore): Tuple {
    if(kvs == null) {
      return Tuple.create([Atom.create("error"), "Type does not exist"]);
    }
    var ref: Reference = Reference.create();
    stores.set(ref, kvs);
    return Tuple.create([Atom.create("ok"), ref]);
  }

  public static inline function destroy(ref: Reference): Atom {
    var kvs: KeyValueStore = stores.get(ref);
    if(kvs != null) {
      kvs.dispose();
      stores.remove(ref);
      return Atom.create("ok");
    } else {
      return Atom.create("not_found");
    }
  }

  public static inline function store(ref: Reference, key: String, value: Dynamic): Atom {
    var kvs: KeyValueStore = stores.get(ref);
    if(kvs != null) {
      return kvs.store(key, value);
    } else {
      return Atom.create("not_found");
    }
  }

  public static inline function fetch(ref: Reference, key: String): Tuple {
    var kvs: KeyValueStore = stores.get(ref);
    if(kvs != null) {
      return kvs.fetch(key);
    } else {
      return Tuple.create([Atom.create("error"), Atom.create("not_found")]);
    }
  }

  public static inline function delete(ref: Reference, key: String): Atom {
    var kvs: KeyValueStore = stores.get(ref);
    if(kvs != null) {
      return kvs.delete(key);
    } else {
      return Atom.create("not_found");
    }
  }

  public static inline function clear(ref: Reference): Atom {
    var kvs: KeyValueStore = stores.get(ref);
    if(kvs != null) {
      return kvs.clear();
    } else {
      return Atom.create("not_found");
    }
  }

  public static inline function getAndUpdate(ref: Reference, key: String, value: Dynamic): Tuple {
    var kvs: KeyValueStore = stores.get(ref);
    if(kvs != null) {
      return kvs.getAndUpdate(key, value);
    } else {
      return Tuple.create([Atom.create("error"), Atom.create("not_found")]);
    }
  }

  public static inline function getAndRemove(ref: Reference, key: String): Tuple {
    var kvs: KeyValueStore = stores.get(ref);
    if(kvs != null) {
      return kvs.getAndRemove(key);
    } else {
      return Tuple.create([Atom.create("error"), Atom.create("not_found")]);
    }
  }

  public static inline function exists(ref: Reference, key: String): Atom {
    var kvs: KeyValueStore = stores.get(ref);
    if(kvs != null) {
      return kvs.exists(key);
    } else {
      return Atom.create("not_found");
    }
  }
}
