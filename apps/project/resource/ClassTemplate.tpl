package;
import util.StringUtil;
import lang.AtomSupport;
import vm.Classes;
import vm.Pid;
import vm.Port;
import IO;
import vm.Function;
import haxe.io.*;
import vm.Reference;
import CPPCLIInput;
import lang.UserDefinedType;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defmodule(AppCode, {
  @alias vm.Classes;
  @alias vm.Lang;
  @alias util.StringUtil;
  @alias util.File;
  @alias vm.Reference;

  @def get_modules([LList], {
    @native Classes.getModules();
  });

  @def get_api({Atom: module}, [LList], {
    @native Classes.getApiFunctions(module);
  });

  @def get_functions({Atom: module}, [LList], {
    @native Classes.getFunctions(module);
  });

  @def compile({String: file_path}, [Tuple], {
    [@_'ok', content] = @native File.getContent(file_path);
    @native Lang.eval(content);
  });

  @def compile_path({String: path, String: base_path}, [Tuple], {
    path = @native StringUtil.concat(base_path, path);
    compile_path(path);
  });

  @def compile_path({String: path}, [Tuple], {
    ref = @native Lang.beginTransaction();
    files = @native File.readDirectory(path);
    path = @native StringUtil.concat(path, '/');
    compile_files(ref, path, files);
  });

  @def compile_files({Reference: ref, String: _, LList: {}}, [Tuple], {
    @native Lang.commit(ref);
  });

  @def compile_files({Reference: ref, String: path, LList: {file | files;}}, [Tuple], {
    file_path = @native StringUtil.concat(path, file);
    [@_'ok', content] = @native File.getContent(file_path);
    result = @native Lang.read(ref, cast(content, String));
    handle_compile_result(ref, result, path, cast(files, LList));
  });

  @def handle_compile_result({Reference: _, Tuple: [@_'error', message], String: _, LList: _}, [Tuple], {
    @native IO.inspect(message);
    [@_'error', message];
  });

  @def handle_compile_result({Reference: ref, Tuple: _, String: path, LList: files}, [Tuple], {
    compile_files(ref, path, cast(files, LList));
  });

  @def anna_lang_home([String], {
    home = @native Lang.annaLangHome();
    @native StringUtil.concat(home, '/');
  });
}))
::foreach source_files::
::source_code::
::end::
@:build(lang.macros.AnnaLang.do_compile())
@:build(lang.macros.AnnaLang.finalize())
class Code {
//  public function getPorts(): Array<Port> {
//    return [CPPCLIInput];
//  }
}
