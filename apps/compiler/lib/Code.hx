package ;
import util.StringUtil;
import lang.AtomSupport;
import vm.Classes;
import vm.Pid;
import vm.Port;
import IO;
import vm.Function;
import vm.Reference;
import CPPCLIInput;
import lang.UserDefinedType;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.deftype(FooCus, {
  var name: String;
}))
@:build(lang.macros.AnnaLang.defmodule(UseState, {
  @def test([FooCus], {
    foo = FooCus%{
      name: 'Foo'
    };

    @native IO.inspect(foo);
    @native vm.NativeKernel.printScope();
    send_foo(foo);
    foo;
  });

  @def send_foo({FooCus: foo}, [FooCus], {
    @native vm.NativeKernel.printScope();
    @native IO.inspect(foo);
    @native IO.inspect(foo.name);
    name = foo.name;
    @native IO.inspect(name);
    foo;
  });
}))
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

  @def defined({Atom: module}, [Atom], {
    @native Classes.defined(module);
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
    handle_compile_result(ref, result, path, file_path, cast(files, LList));
  });

  @def handle_compile_result({Reference: _, Tuple: [@_'execution_error', message], String: path, String: file_path, LList: _}, [Tuple], {
    @native IO.inspect(file_path);
    @native IO.inspect(message);
    [@_'error', message];
  });

  @def handle_compile_result({Reference: ref, Tuple: _, String: path, String: _, LList: files}, [Tuple], {
    compile_files(ref, path, cast(files, LList));
  });

  @def anna_lang_home([String], {
    home = @native Lang.annaLangHome();
    @native StringUtil.concat(home, '/');
  });
}))
@:build(lang.macros.AnnaLang.defmodule(CompilerMain, {
  @alias vm.NativeKernel;
  @alias vm.Lang;
  @alias util.StringUtil;

  @def start([Atom], {
    main = @native StringUtil.concat(AppCode.anna_lang_home(), 'apps/bootstrap/boot_main.anna');
    result = AppCode.compile(main);
    @native Lang.eval('BootMain.start()');
    @_'ok';
  });
}))
@:build(lang.macros.AnnaLang.do_compile())
class Code {

}
