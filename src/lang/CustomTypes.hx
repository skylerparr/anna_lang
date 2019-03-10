package lang;

interface CustomType {}

class CustomTypes {
  public static function set(obj: CustomType, field: String, value: Dynamic): CustomType {
    Reflect.setField(obj, field, value);
    return obj;
  }
}