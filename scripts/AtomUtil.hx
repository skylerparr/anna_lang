package;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class AtomUtil {
  public static function toString(atom: Atom): String {
    return atom.value;
  }
}