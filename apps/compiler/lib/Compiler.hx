package ;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defcls(CompilerMain, {
//  @defmodule Anna({
//    @redef operator(@_"=", "assign");
//
//    @defmacro assign({Tuple: lhs, Tuple: rhs}, [Tuple], {
//      quote({
//
//      });
//    });
//
//  });
  @def start({
    @native IO.inspect("hello world");
    result = match([@_"ok", "sad"]);
    @native IO.inspect(result);

//    [@_"ok", val] = call_thing("foo");

    @_"nil";
  });

  @def match({Tuple: rhs}, [Dynamic], {
    fun = @fn {
      ([{Tuple: [@_"ok", val]}, [String]] => {
        val;
      });
    }
    fun(rhs);
  });
}))
@:build(lang.macros.AnnaLang.compile())
class Compiler {

}