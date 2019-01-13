package ;
@:build(macros.ScriptMacros.script())
class Atom {
  public static function toString(atom: lang.Types.Atom): String {
    return atom.value;
  }
}
