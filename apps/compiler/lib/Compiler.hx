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

  @def substring({String: string, Int: start, Int: end}, [String], {
    @native StringUtil.substring(string, start, end);
  });

  @def length({String: string}, [Int], {
    @native StringUtil.length(string);
  });

  @def rpad({String: string, String: c_string, Int: length}, [String], {
    @native StringUtil.rpad(string, c_string, length);
  });

}))
@:build(lang.macros.AnnaLang.defcls(File, {

  @def get_content({String: file_path}, [String], {
    #if cpp
    @native sys.io.File.getContent(file_path);
    #else
    '';
    #end
  });
}))
@:build(lang.macros.AnnaLang.defcls(System, {
  @def print({String: str}, [Atom], {
    @native IO.print(str);
  });

  @def println({String: str}, [Atom], {
    @native IO.println(str);
  });
}))
@:build(lang.macros.AnnaLang.defcls(CommandHandler, {
  @alias vm.Kernel;

  @def process_command({String: 'exit'}, [Atom], {
    System.println('');
    System.println('exiting...');
    @native Kernel.stop();
    @_'nil';
  });

  @def process_command({String: 'recompile'}, [Atom], {
    System.println('');
    @native Kernel.recompile();
    @native Kernel.stop();
    @_'ok';
  });

  @def process_command({String: 'compile_vm'}, [Atom], {
    System.println('');
    @native Kernel.compileVM();
    @native Kernel.stop();
    @_'ok';
  });

  @def process_command({String: 'haxe'}, [Atom], {
    System.println('');
    @native Kernel.switchToHaxe();
    @native Kernel.stop();
    @_'nil';
  });

  @def process_command({String: ''}, [Atom], {
    System.println('');
    CompilerMain.prompt();
  });

  @def process_command({String: cmd}, [Atom], {
    System.println('');
    System.println(cmd);
    CompilerMain.prompt();
  });
}))
@:build(lang.macros.AnnaLang.defcls(CompilerMain, {
  @alias vm.Process;
  @alias vm.Kernel;

  @def start({
    self = @native Process.self();
    System.println('Interacive Anna version 0.0.0');
    prompt();
  });

  @def prompt([Atom], {
    System.print('ia> ');
    collect_user_input('');
  });

  @def collect_user_input({String: current_string}, [String], {
    input = @native IO.getsCharCode();
    handle_input(input, current_string);
  });

  // enter
  @def handle_input({Int: 13, String: current_string}, [String], {
    CommandHandler.process_command(current_string);
  });

  // ctrl+d
  @def handle_input({Int: 4, String: current_string}, [String], {
    System.println('');
    System.println('exiting...');
    @native Kernel.stop();
    @_'nil';
  });

  // backspace
  @def handle_input({Int: 127, String: current_string}, [String], {
    len = Str.length(current_string);
    len = @native Kernel.subtract(len, 1);
    current_string = Str.substring(current_string, 0, len);
    string_to_print = Str.concat('ia> ', current_string);
    string_to_print = Str.concat('\r', string_to_print);
    new_prompt = Str.concat(string_to_print, ' ');
    System.print(new_prompt);
    System.print(string_to_print);
    collect_user_input(current_string);
  });

  @def handle_input({Int: code, String: current_string}, [String], {
    str = Str.from_char_code(code);
    System.print(str);
    current_string = Str.concat(current_string, str);
    collect_user_input(current_string);
  });

}))
@:build(lang.macros.AnnaLang.compile())
class Compiler {

}
