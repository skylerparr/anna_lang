package ;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defcls(Str, {
  @alias vm.Kernel;

  @def concat({String: lhs, String: rhs}, [String], {
    @native Kernel.concat(lhs, rhs);
  });
}))
@:build(lang.macros.AnnaLang.defcls(CompilerMain, {
  @def start({
    @native IO.inspect("hello world");
    collect_user_input('');
  });

  @def collect_user_input({String: current_string}, [String], {
    input = @native IO.gets();
    current_string = Str.concat(current_string, input);
    collect_user_input(current_string);
  });
}))
@:build(lang.macros.AnnaLang.compile())
class Compiler {

}