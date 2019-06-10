package;

import lang.CustomTypes.CustomType;
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

  public function toHaxeString(): String {
    return 'new KeyValue<>(${key}, ${value})';
  }

  public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
    var retVal: Array<String> = [];
    for(pattern in patternArgs) {
      retVal.push('${pattern.key}: ${pattern.value}');
    }
    return '{${retVal.join(', ')}}';
  }

}