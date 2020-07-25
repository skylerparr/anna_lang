package vm.kvs;

import core.BaseObject;
import sys.thread.Mutex;

class CPPReadConcurrentKVS extends MapKVS {

  private var mutex: Mutex;

  public function new() {
    super();
    mutex = new Mutex();
  }

  override public function store(key: String, value: Dynamic): Atom {
    mutex.acquire();
    var retVal = super.store(key, value);
    mutex.release();
    return retVal;
  }

  override public function delete(key: String): Atom {
    mutex.acquire();
    var retVal = super.delete(key);
    mutex.release();
    return retVal;
  }

  override public function clear(): Atom {
    mutex.acquire();
    var retVal = super.clear();
    mutex.release();
    return retVal;
  }

  override public function getAndUpdate(key: String, newValue: Dynamic): Tuple {
    mutex.acquire();
    var retVal = super.getAndUpdate(key, newValue);
    mutex.release();
    return retVal;
  }

  override public function getAndRemove(key: String): Tuple {
    mutex.acquire();
    var retVal = super.getAndRemove(key);
    mutex.release();
    return retVal;
  }
}
