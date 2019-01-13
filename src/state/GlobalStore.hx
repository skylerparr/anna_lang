package state;
class GlobalStore {

  private static var state: Map<String, Dynamic>;

  public static function start():Void {
    state = new Map<String, Dynamic>();
  }

  public static function set(name:String, value:Dynamic):Void {
    state.set(name, value);
  }

  public static function get(name:String):Dynamic {
    return state.get(name);
  }

  public static function exists(name:String):Bool {
    return state.exists(name);
  }

}
