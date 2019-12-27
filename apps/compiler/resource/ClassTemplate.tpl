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
::foreach source_files::
::source_code::
::end::
@:build(lang.macros.AnnaLang.compile())
class Code {
  public static function defineCode(): Atom {
    vm.Classes.define(Atom.create('System'), System);
    ::foreach source_files::
    ::if (module_type == "module")::
    vm.Classes.define(Atom.create('::module_name::'), ::module_name::);
    ::end::
    ::end::
    return Atom.create('ok');
  }
}