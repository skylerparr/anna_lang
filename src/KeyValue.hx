package;

import lang.CustomType;
class KeyValue<K, V> implements CustomType {
  public var key(default, never): K;
  public var value(default, never): V;

  public inline function new(key: K, value: V) {
    Reflect.setField(this, 'key', key);
    Reflect.setField(this, 'value', value);
  }

  public function toAnnaString(): String {
    return '%KeyValue{key: ${key}, value: ${value}}';
  }

}