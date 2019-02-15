package;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class AtomUtil {
  public static function toString(atom: lang.Types.Atom): String {
    return atom.value;
  }
}