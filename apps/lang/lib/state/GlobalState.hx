package state;

using lang.AtomSupport;

class GlobalState {
  private static inline var globalState: String = "state.GlobalStore";

  public static function init(key:String):Atom {
    if(!Native.callStatic(globalState, "exists", [key])) {
      Native.callStatic(globalState, "set", [key, {}]);
    }
    return 'ok'.atom();
  }

  public static function get(key:String):Dynamic {
    init(key);
    return Native.callStatic(globalState, "get", [key]);
  }
}
