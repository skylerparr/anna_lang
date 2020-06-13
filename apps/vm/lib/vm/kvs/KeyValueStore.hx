package vm.kvs;
import core.BaseObject;

interface KeyValueStore extends BaseObject {
  function store(key: String, value: Dynamic): Atom;
  function fetch(key: String): Tuple;
  function delete(key: String): Atom;
  function clear(): Atom;
  function getAndUpdate(key: String, newValue: Dynamic): Tuple;
  function getAndRemove(key: String): Tuple;
  function exists(key: String): Atom;
}
