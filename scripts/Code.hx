package ;
import lang.Types;
import lang.Types.Atom;

using lang.AtomSupport;

@:build(macros.ValueClassImpl.build())
class Code {

  @field public static var functionMap: Map<Atom, Dynamic>;

  public static function start(): Atom {
    functionMap = new Map<Atom, Dynamic>();
    return 'ok'.atom();
  }

  public static function findFunction(name: Atom): Dynamic {
    return functionMap.get(name);
  }

  public static function define(name: Atom, func: Dynamic): Tuple {
    functionMap.set(name, func);
    return {type: Types.TUPLE, value: ['ok'.atom()]};
  }

}
