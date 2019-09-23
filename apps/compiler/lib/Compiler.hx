package ;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defcls(CompilerMain, {
  @def start({
    @native IO.inspect("hello world");
    result = match([@_"ok", "sad"]);
    @_"nil";
  });

  @def match({Tuple: rhs}, [String], {
    @native IO.inspect(rhs);
    'ok';
  });
}))
@:build(lang.macros.AnnaLang.compile())
class Compiler {

}