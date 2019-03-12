package lang;

interface CustomType {
  function toAnnaString(): String;
  function toHaxeString(): String;
  function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String;
}

class CustomTypes {
  public static function set(obj: CustomType, field: String, value: Dynamic): CustomType {
    Reflect.setField(obj, field, value);
    return obj;
  }
}