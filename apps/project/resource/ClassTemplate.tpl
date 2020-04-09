package;
import util.StringUtil;
import lang.AtomSupport;
import vm.Classes;
import vm.Pid;
import vm.Port;
import IO;
import vm.Function;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defmodule(AppCode, {
  @alias vm.Classes;
  @alias vm.Lang;

  @def get_modules([LList], {
    @native Classes.getModules();
  });

  @def get_api({Atom: module}, [LList], {
    @native Classes.getApiFunctions(module);
  });

  @def compile({String: file_path}, [Tuple], {
    #if cpp
    content = @native sys.io.File.getContent(file_path);
    #else
    content = '';
    #end
    @native Lang.eval(content);
  });
}))
::foreach source_files::
::source_code::
::end::
@:build(lang.macros.AnnaLang.do_compile())
class Code {
}