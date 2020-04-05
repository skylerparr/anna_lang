package;
import util.StringUtil;
import lang.AtomSupport;
import vm.Classes;
import vm.Pid;
import vm.Port;
import IO;
import vm.Function;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defmodule(System, {
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
@:build(lang.macros.AnnaLang.do_compile())
class Code {
}