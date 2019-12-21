package ;
import vm.Kernel;
import vm.Pid;
import IO;
import vm.Function;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defCls(Str, {
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

  @def string_to_int({String: s}, [Int], {
    @native Std.int(s);
  });

  @def random({Int: length}, [String], {
    @native StringUtil.random(length);
  });
}))
@:build(lang.macros.AnnaLang.defCls(File, {
  @def get_content({String: file_path}, [String], {
    #if cpp
    @native sys.io.File.getContent(file_path);
    #else
    '';
    #end
  });
}))
@:build(lang.macros.AnnaLang.defCls(Kernel, {
  @alias vm.Pid;
  @alias vm.Kernel;
  @alias vm.Function;

  @def receive({Function: fun}, [Dynamic], {
    @native Kernel.receive(fun);
  });

  @def send({Pid: pid, Tuple: value}, [Atom], {
    @native Kernel.send(pid, value);
    @_'ok';
  });

  @def spawn({Atom: module, Atom: func, Tuple: types, LList: args}, [Pid], {
    @native Kernel.spawn(module, func, types, args);
  });

  @def spawn_link({Atom: module, Atom: func, Tuple: types, LList: args}, [Pid], {
    @native Kernel.spawn_link(module, func, types, args);
  });

  @def add({Float: a, Float: b}, [Float], {
    @native Kernel.add(a, b);
  });

  @def subtract({Float: a, Float: b}, [Float], {
    @native Kernel.subtract(a, b);
  });
}))
@:build(lang.macros.AnnaLang.defCls(System, {
  @def print({String: str}, [Atom], {
    @native IO.print(str);
  });

  @def println({String: str}, [Atom], {
    @native IO.println(str);
  });
}))
@:build(lang.macros.AnnaLang.defCls(CommandHandler, {
  @alias vm.Kernel;
  @const ANNA_LANG_SRC_PATH = 'anna_lang/';
  @const ANNA_LANG_SUFFIX = '.anna';

  @def process_command({String: 'exit'}, [Atom], {
    System.println('exiting...');
    @native Kernel.stop();
    @_'nil';
  });

  @def process_command({String: 'recompile'}, [Atom], {
    @native Kernel.recompile();
    @native Kernel.stop();
    @_'nil';
  });


  @def process_command({String: 'compile_vm'}, [Atom], {
    @native Kernel.compileVM();
    @native Kernel.stop();
    @_'nil';
  });

  @def process_command({String: 'haxe'}, [Atom], {
    @native Kernel.switchToHaxe();
    @native Kernel.stop();
    @_'nil';
  });

  @def process_command({String: 'tests'}, [Atom], {
    UnitTests.run_tests();
    @_'ok';
  });

  @def process_command({String: 'v ' => number}, [String], {
    //todo: need to infer string pattern matches
    index = Str.string_to_int(cast(number, String));
    index = Kernel.subtract(index, 1);
    command = History.get(cast(index, Int));
    System.println(command);
    @_'ok';
  });

  @def process_command({String: 'c ' => file}, [Atom], {
    filename = cast(file, String);
    filename = Str.concat(ANNA_LANG_SRC_PATH, filename);
    filename = Str.concat(filename, ANNA_LANG_SUFFIX);
    content = File.get_content(filename);
    AnnaCompiler.parse(content);
    @_'ok';
  });

  @def process_command({String: ''}, [Atom], {
    @_'ok';
  });

  @def process_command({String: cmd}, [Atom], {
    History.push(cmd);

    System.println(cmd);
    @_'ok';
  });
}))
@:build(lang.macros.AnnaLang.defCls(AnnaCompiler, {
  @alias util.Template;
  @const TEMPLATE = 'package;
import vm.Kernel;
import vm.Pid;
import IO;
import vm.Function;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.::code::
@:build(lang.macros.AnnaLang.compile())
class ::filename:: {

}';

  @def parse({String: code}, [Atom], {
    filename = Str.random(30);
    @native IO.inspect([@_'filename' => filename]);
    result = @native Template.execute(TEMPLATE, [@_'filename' => filename]);
    @native IO.inspect(result);
    @_'ok';
  });
}))
@:build(lang.macros.AnnaLang.defCls(History, {
  @alias vm.Process;
  @alias vm.Kernel;
  @alias vm.Pid;

  @const PID_HISTORY = @_'history';

  @def start([Tuple], {
    history_pid = @native Kernel.spawn(@_'History', @_'start_history', [], {});
    @native Process.registerPid(history_pid, PID_HISTORY);

    [@_'ok', history_pid];
  });

  @def start_history([String], {
    history_loop([1, {}, 0]);
  });

  @def history_loop({Tuple: history}, [Tuple], {
    received = Kernel.receive(@fn {
      ([{Tuple: [@_'current_line', @_'inc']}] => {
        [current_line, commands, scroll_pos] = history;
        current_line = Kernel.add(cast(current_line, Int), 1);
        [current_line, commands, scroll_pos];
      });
      ([{Tuple: [@_'current_line', @_'get', pid]}] => {
        [current_line, _, _] = history;
        @native Kernel.send(pid, current_line);
        history;
      });
      ([{Tuple: [@_'scroll', @_'back', pid]}] => {
        [current_line, commands, scroll_pos] = history;
        scroll_pos = Kernel.subtract(cast(scroll_pos, Int), 1);
        handle_history(cast(commands, LList), cast(pid, Pid), scroll_pos);
        [current_line, commands, scroll_pos];
      });
      ([{Tuple: [@_'scroll', @_'forward', pid]}] => {
        [current_line, commands, scroll_pos] = history;
        scroll_pos = Kernel.add(cast(scroll_pos, Int), 1);
        handle_history(cast(commands, LList), cast(pid, Pid), scroll_pos);
        [current_line, commands, scroll_pos];
      });
      ([{Tuple: [@_'push', val]}, [Tuple]] => {
        [current_line, commands, scroll_pos] = history;
        commands = @native LList.add(commands, val);
        scroll_pos = @native LList.length(commands);
        [current_line, commands, scroll_pos];
      });
      ([{Tuple: [@_'get', index, respond]}, [Tuple]] => {
        [_, commands, _] = history;
        value = @native LList.getAt(commands, index);
        @native Kernel.send(cast(respond, Pid), cast(value, String));
        history;
      });
    });
    history_loop(cast(received, Tuple));
  });

  @def handle_history({LList: {}, Pid: pid, Int: _}, [Atom], {
    @native Kernel.send(pid, '');
  });

  @def handle_history({LList: commands, Pid: pid, Int: scroll_pos}, [Atom], {
    total_commands = @native LList.length(commands);
    command = @native LList.getAt(commands, scroll_pos);
    @native Kernel.send(pid, command);
  });

  @def increment_line([Atom], {
    pid = @native Process.getPidByName(PID_HISTORY);
    Kernel.send(pid, [@_'current_line', @_'inc']);
  });

  @def get_counter([Int], {
    pid = @native Process.getPidByName(PID_HISTORY);
    self = @native Process.self();
    Kernel.send(pid, [@_'current_line', @_'get', self]);
    Kernel.receive(@fn {
      ([{Int: line}, [Int]] => {
        line;
      });
    });
  });

  @def push({String: command}, [Atom], {
    pid = @native Process.getPidByName(PID_HISTORY);
    Kernel.send(pid, [@_'push', command]);
    @_'ok';
  });

  @def get({Int: index}, [String], {
    pid = @native Process.getPidByName(PID_HISTORY);
    self = @native Process.self();
    Kernel.send(pid, [@_'get', index, self]);
    Kernel.receive(@fn {
      ([{String: command}, [String]] => {
        command;
      });
    });
  });

  @def back([String], {
    pid = @native Process.getPidByName(PID_HISTORY);
    self = @native Process.self();
    Kernel.send(pid, [@_'scroll', @_'back', self]);
    Kernel.receive(@fn {
      ([{String: command}, [String]] => {
        command;
      });
    });
  });

  @def forward([String], {
    pid = @native Process.getPidByName(PID_HISTORY);
    self = @native Process.self();
    Kernel.send(pid, [@_'scroll', @_'forward', self]);
    Kernel.receive(@fn {
      ([{String: command}, [String]] => {
        command;
      });
    });
  });
}))
@:build(lang.macros.AnnaLang.defCls(CompilerMain, {
  @alias vm.Process;
  @alias vm.Kernel;

  @const VSN = '0.0.0';
  @const PREFIX = 'ia(';

  @def start({
    status = History.start();
    UnitTests.start();

    welcome = Str.concat('Interacive Anna version ', VSN);
    System.println(welcome);
    prompt();
  });

  @def prompt([Atom], {
    prompt_string = get_prompt();
    System.print(prompt_string);
    collect_user_input('');
  });

  @def get_prompt([String], {
    counter = History.get_counter();
    prefix = Str.concat(PREFIX, cast(counter, String));
    Str.concat(prefix, ')> ');
  });

  @def collect_user_input({String: current_string}, [String], {
    input = @native IO.getsCharCode();
    handle_input(input, current_string);
  });

  @def handle_result({Atom: @_'ok'}, [Atom], {
    prompt();
  });

  @def handle_result({Atom: _}, [Atom], {
    @_'nil';
  });

  // enter
  @def handle_input({Int: 13, String: current_string}, [String], {
    System.println('');
    History.increment_line();
    result = CommandHandler.process_command(current_string);
    handle_result(result);
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
    clear_prompt(current_string);
    len = Str.length(current_string);
    len = @native Kernel.subtract(len, 1);
    current_string = Str.substring(current_string, 0, len);
    print_prompt(current_string);
  });

  // up arrow
  @def handle_input({Int: 65, String: current_string}, [String], {
    clear_prompt(current_string);
    current_string = History.back();
    System.print('i');
    print_prompt(current_string);
  });

  // down arrow
  @def handle_input({Int: 66, String: current_string}, [String], {
    clear_prompt(current_string);
    current_string = History.forward();
    System.print('i');
    print_prompt(current_string);
  });

  // right arrow
  @def handle_input({Int: 67, String: current_string}, [String], {
    collect_user_input(current_string);
  });

  // left arrow
  @def handle_input({Int: 68, String: current_string}, [String], {
    collect_user_input(current_string);
  });

  // ctrl+u
  @def handle_input({Int: 21, String: current_string}, [String], {
    clear_prompt(current_string);
    print_prompt('');
  });

  @def handle_input({Int: code, String: current_string}, [String], {
    str = Str.from_char_code(code);
    System.print(str);
    current_string = Str.concat(current_string, str);
    collect_user_input(current_string);
  });

  @def clear_prompt({String: current_string}, {
    str_len = Str.length(current_string);
    str_len = Kernel.add(str_len, 10);
    clear_string = Str.rpad('\r', ' ', str_len);
    System.print(clear_string);
  });

  @def print_prompt({String: current_string}, {
    str_prompt = get_prompt();
    str_prompt = Str.concat(str_prompt, current_string);
    str_prompt = Str.concat('\r', str_prompt);
    str_prompt = Str.rpad(str_prompt, ' ', 7);
    System.print(str_prompt);
    collect_user_input(current_string);
  });

}))
@:build(lang.macros.AnnaLang.defCls(UnitTests, {
  @alias vm.Process;
  @alias vm.Kernel;

  @const ALL_TESTS = @_'ALL Tests';

  @def start([Tuple], {
    all_tests_pid = Kernel.spawn(@_'UnitTests', @_'start_tests_store', cast([], Tuple), {});
    @native Process.registerPid(all_tests_pid, ALL_TESTS);
    [@_'ok', all_tests_pid];
  });

  @def start_tests_store([LList], {
    tests_store_loop({});
  });

  @def tests_store_loop({LList: all_tests}, [LList], {
    received = Kernel.receive(@fn {
      ([{Tuple: [@_'store', test_module, test_name]}] => {
        @native LList.add(all_tests, [test_module, test_name]);
      });
      ([{Tuple: [@_'get', respond_pid]}] => {
        @native Kernel.send(respond_pid, all_tests);
        all_tests;
      });
    });
    tests_store_loop(cast(received, LList));
  });

  @def add_test({Atom: module, Atom: func}, [Atom], {
    all_tests_pid = @native Process.getPidByName(ALL_TESTS);
    Kernel.send(all_tests_pid, [@_'store', module, func]);
    @_'ok';
  });

  @def run_tests([Atom], {
    all_tests_pid = @native Process.getPidByName(ALL_TESTS);
    self = @native Process.self();
    Kernel.send(all_tests_pid, [@_'get', self]);
    all_tests = Kernel.receive(@fn {
      ([{LList: all_tests}] => {
        all_tests;
      });
    });
    do_run_tests(cast(all_tests, LList));
    @_'ok';
  });

  @def do_run_tests({LList: {}}, [Atom], {
    @_'ok';
  });

  @def do_run_tests({LList: {first | rest;}}, [Atom], {
    run_test(cast(first, Tuple));
    do_run_tests(cast(rest, LList));
    @_'ok';
  });

  @def run_test({Tuple: [module, func]}, [Atom], {
    @_'ok';
  });
}))
@:build(lang.macros.AnnaLang.defCls(Assert, {
  @def are_equal({String: lhs, String: rhs}, [Atom], {
    @_'ok';
  });
}))
@:build(lang.macros.AnnaLang.defCls(ASTTests, {
  @def should_convert_int_to_ast([Atom], {
    @_'ok';
  });
}))
@:build(lang.macros.AnnaLang.compile())
class Compiler {

}
