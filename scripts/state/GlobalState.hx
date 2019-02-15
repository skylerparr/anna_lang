package state;

using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class GlobalState {
  private static inline var globalState: String = "state.GlobalStore";

  public static function init(key:String, value:Dynamic):Atom {
    if(!Native.callStatic(globalState, "exists", [key])) {
      Native.callStatic(globalState, "set", [key, value]);
    }
    return 'ok'.atom();
  }

  public static function get(key:String):Dynamic {
    return Native.callStatic(globalState, "get", [key]);
  }
}
