package main;
import vm.Kernel;
import vm.Pid;
import IO;
import vm.Function;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defCls(System, {
  @def print({String: str}, [Atom], {
    @native IO.print(str);
  });

  @def println({String: str}, [Atom], {
    @native IO.println(str);
  });
}))
@:build(lang.macros.AnnaLang.::code::)
@:build(lang.macros.AnnaLang.compile())
class Code {
  public static function defineCode(): Atom {
    vm.Classes.define(Atom.create('System'), System);
    vm.Classes.define(Atom.create('::module_name::'), ::module_name::);
    return Atom.create('ok');
  }
}