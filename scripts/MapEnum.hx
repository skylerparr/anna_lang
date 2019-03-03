package;

using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class MapEnum {

  @:generic
  public static function reduce<T, K, E, F>(map: Map<T, K>, accumulator: Map<E, F>, fun: Array<Dynamic>->Map<E, F>->Map<E, F>): Map<E, F> {
    for(i in map.keys()) {
      var kv: Array<Dynamic> = [i, map.get(i)];
      accumulator = fun(kv, accumulator);
    }
    return accumulator;
  }

}