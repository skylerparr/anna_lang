package ;
class IO {
  public static function inspect(value: Dynamic): Dynamic {
    Logger.inspect(value);
    return value;
  }
}
