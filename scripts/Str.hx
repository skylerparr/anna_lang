package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Str {
  public static function toAtom(str: String): lang.Types.Atom {
    return str.atom();
  }
}
