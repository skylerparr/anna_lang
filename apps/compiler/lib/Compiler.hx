package ;
import util.StringUtil;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defcls(Str, {
  @alias util.StringUtil;

  @def concat({String: lhs, String: rhs}, [String], {
    @native StringUtil.concat(lhs, rhs);
  });

  @def from_char_code({Int: char_code}, [String], {
    @native StringUtil.fromCharCode(char_code);
  });
}))
@:build(lang.macros.AnnaLang.defcls(CompilerMain, {
  @alias vm.Process;

  @def start({
    println('Interacive Anna version 0.0.0');
    print('ia> ');
    collect_user_input('');
  });

  @def collect_user_input({String: current_string}, [String], {
    input = @native IO.getsCharCode();
    handle_input(input, current_string);
  });

  @def handle_input({Int: 13, String: current_string}, [String], {
    println('');
    println(current_string);
    print('ia> ');
    collect_user_input('');
  });

  @def handle_input({Int: 4, String: current_string}, [String], {
    println('exiting');
    @_'nil';
  });

  @def handle_input({Int: 127, String: current_string}, [String], {
    collect_user_input(current_string);
  });

  @def handle_input({Int: code, String: current_string}, [String], {
    str = Str.from_char_code(code);
    print(str);
    current_string = Str.concat(current_string, str);
    collect_user_input(current_string);
  });

  @def print({String: str}, [Atom], {
    @native IO.print(str);
  });

  @def println({String: str}, [Atom], {
    @native IO.println(str);
  });
}))
@:build(lang.macros.AnnaLang.compile())
class Compiler {

}
