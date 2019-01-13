package ;

import lang.Types.Atom;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Kernel {
  public static var parser: Dynamic;
  public static var interp: Dynamic;

  public static function add(args: Array<Int>): Int {
    switch(args) {
      case [a,b]:
        return a+b;
      case _:
        return 0;
    }
  }

  public static function defmacro(name: Atom, args: Array<Dynamic>): Void {

  }

  public static function apply(modFun: Atom, args: Array<Dynamic>): Dynamic {
    return 'undefined'.atom();
  }



}
