package ;
import util.StringUtil;
import lang.AtomSupport;
import vm.Classes;
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

  @def nameify({String: str}, [String], {
    @native StringUtil.nameify(str);
  });

  @def ends_with({String: str, String: other_str}, [Atom], {
    @native StringUtil.endsWith(str, other_str);
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

  @def save_content({String: file_path, String: content}, [Tuple], {
    #if cpp
    @native sys.io.File.saveContent(file_path, content);
    [@_'ok', file_path];
    #else
    [@_'error', 'not supported'];
    #end
  });

  @def mkdir_p({String: dir}, [Tuple], {
    #if cpp
    @native sys.FileSystem.createDirectory(dir);
    [@_'ok', dir];
    #else
    [@_'error', 'not supported'];
    #end
  });

  @def rm_rf({String: dir}, [Tuple], {
    #if cpp
    @native util.File.removeAll(dir);
    #else
    [@_'error', 'not supported'];
    #end
  });

  @def cp({String: src, String: dest}, [Tuple], {
    #if cpp
    @native sys.io.File.copy(src, dest);
    [@_'ok', file_path];
    #else
    [@_'error', 'not supported'];
    #end
  });

  @def ls({String: dir}, [Tuple], {
    #if cpp
    files = @native util.File.readDirectory(dir);
    [@_'ok', files];
    #else
    [@_'error', 'not supported'];
    #end
  });

  @def is_dir({String: dir}, [Tuple], {
    #if cpp
    result = @native util.File.isDirectory(dir);
    [@_'ok', result];
    #else
    [@_'error', 'not supported'];
    #end
  });
}))
@:build(lang.macros.AnnaLang.defCls(JSON, {
  @def parse({String: data}, [Tuple], {
    @native util.JSON.parse(data);
  });

  @def stringify({Tuple: [@_'ok', data]}, [Tuple], {
    @native util.JSON.stringify(data);
  });
}))
@:build(lang.macros.AnnaLang.defCls(Kernel, {
  @alias vm.Pid;
  @alias vm.Kernel;
  @alias vm.Function;

  @def stop({
    @native Kernel.stop();
  });

  @def receive({Function: fun}, [Dynamic], {
    @native Kernel.receive(fun);
  });

  @def send({Pid: pid, Tuple: value}, [Atom], {
    @native Kernel.send(pid, value);
    @_'ok';
  });

  @def self([Pid], {
    @native vm.Process.self();
  });

  @def monitor({Pid: pid}, [Atom], {
    @native Kernel.monitor(pid);
  });

  @def demonitor({Pid: pid}, [Atom], {
    @native Kernel.demonitor(pid);
  });

  @def spawn({Atom: module, Atom: func}, [Pid], {
    @native Kernel.spawn(module, func, [], {});
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

  @def exit({Pid: pid}, [Atom], {
    @native Kernel.exit(pid);
  });
}))
@:build(lang.macros.AnnaLang.defCls(System, {
  @def print({String: str}, [Atom], {
    @native IO.print(str);
  });

  @def println({String: str}, [Atom], {
    @native IO.println(str);
  });

  @def set_cwd({String: str}, [Tuple], {
    @native Sys.setCwd(str);
    [@_'ok', str];
  });

  @def get_cwd([Tuple], {
    cwd = @native Sys.getCwd();
    [@_'ok', cwd];
  });
}))
@:build(lang.macros.AnnaLang.defCls(CommandHandler, {
  @alias vm.Kernel;
  @const PROJECT_SRC_PATH = 'project/';

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

  @def process_command({String: 'self'}, [String], {
    @native IO.inspect(Kernel.self());
    @_'ok';
  });

  @def process_command({String: 'build'}, [Atom], {
    System.set_cwd(PROJECT_SRC_PATH);
    System.println('building project');
    [@_'ok', cwd] = System.get_cwd();
    System.println(cast(cwd, String));
    AnnaCompiler.build_project();
    System.set_cwd('..');
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
@:build(lang.macros.AnnaLang.defApi(EEnum, {
  @def reduce({LList: list, LList: acc, Function: callback}, [List]);
}))
@:build(lang.macros.AnnaLang.defCls(DefaultEnum, {
  @alias vm.Function;
  @impl EEnum;

  @def reduce({LList: {}, LList: acc, Function: _}, [LList], {
    acc;
  });

  @def reduce({LList: {head | rest;}, LList: acc, Function: callback}, [LList], {
    result = callback(head, acc);
    reduce(cast(rest, LList), acc, callback);
  });
}))
@:build(lang.macros.AnnaLang.defType(SourceFile, {
  var module_name: String = '';
  var source_code: String = '';
  var module_type: String = '';
}))
@:build(lang.macros.AnnaLang.defType(ProjectConfig, {
  var app_name: String = '';
  var src_files: LList = {};
}))
@:build(lang.macros.AnnaLang.defCls(AnnaCompiler, {
  @alias util.Template;

  @const PROJECT_SRC_PATH = 'project/';
  @const ANNA_LANG_SUFFIX = '.anna';
  @const HAXE_SUFFIX = '.hx';
  @const BUILD_DIR = '_build/';
  @const LIB_DIR = 'lib/';
  @const OUTPUT_DIR = '_build/apps/main/';
  @const RESOURCE_DIR = '../apps/compiler/resource/';
  @const CONFIG_FILE = 'app_config.json';
  @const BUILD_FILE = 'build.hxml';
  @const CLASS_TEMPLATE_FILE = 'ClassTemplate.tpl';
  @const BUILD_TEMPLATE_FILE = 'build.hxml.tpl';
  @const HAXE_BUILD_MACR0_START = '@:build(lang.macros.AnnaLang.';
  @const HAXE_BUILD_MACR0_END = ')';

  @def build_project([Tuple], {
    clean();
    handle_config(get_config());
  });

  @def clean([Atom], {
    result = File.rm_rf(BUILD_DIR);
    result = File.mkdir_p(OUTPUT_DIR);
    @_'ok';
  });

  @def get_config([Tuple], {
    content = File.get_content(CONFIG_FILE);
    JSON.parse(content);
  });

  @def handle_config({Tuple: [@_'ok', @map["application" => app_name]]}, [Tuple], {
    [@_'ok', files] = gather_source_files(LIB_DIR, {});
    generate_template(cast(files, LList));
    compile_app(cast(app_name, String));
  });

  @def handle_config({Tuple: error}, [Tuple], {
    @native IO.inspect(error);
    error;
  });

  @def gather_source_files({String: dir, LList: ret_val}, [Tuple], {
    [@_'ok', files] = File.ls(dir);
    result = EEnum.reduce(cast(files, LList), {}, @fn {
      ([{String: file, LList: acc}, [LList]] => {
        fun = @fn{
          ([{Atom: @_'true'}, [LList]] => {
            filename = Str.concat(cast(dir, String), cast(file, String));
            content = File.get_content(filename);

            [@_'ok', module_name, module_type] = @native util.AST.getModuleInfo(content);

            content = Str.concat(HAXE_BUILD_MACR0_START, content);
            content = Str.concat(content, HAXE_BUILD_MACR0_END);

            src_file = SourceFile%{source_code: content, module_name: module_name, module_type: module_type};

            @native LList.add(acc, src_file);
          });
          ([{Atom: @_'false'}, [LList]] => {
            acc;
          });
        }
        fun(Str.ends_with(file, ANNA_LANG_SUFFIX));
      });
    });
    [@_'ok', result];
  });

  @def generate_template({LList: source_files}, [Tuple], {
    template_file = Str.concat(RESOURCE_DIR, CLASS_TEMPLATE_FILE);
    template = File.get_content(template_file);
    [@_'ok', result] = @native Template.execute(template, ['source_files' => source_files]);

    filename = 'Code';
    filename = Str.concat(OUTPUT_DIR, filename);
    filename = Str.concat(filename, HAXE_SUFFIX);

    File.save_content(filename, cast(result, String));

    [@_'ok', result];
  });

  @def compile_app({String: app_name}, [Tuple], {
    //copy the app_config
    app_config_destination = Str.concat(OUTPUT_DIR, CONFIG_FILE);
    File.cp(CONFIG_FILE, app_config_destination);

    //update the haxe build file
    template_file = Str.concat(RESOURCE_DIR, BUILD_TEMPLATE_FILE);
    template = File.get_content(template_file);

    [@_'ok', result] = @native Template.execute(template, ["app_name" => app_name]);
    template_file = Str.concat(BUILD_DIR, BUILD_FILE);
    File.save_content(template_file, cast(result, String));

    status = @native util.Compiler.compileProject();
    @native IO.inspect(status);

    [@_'ok', filename, result];
  });
}))
@:build(lang.macros.AnnaLang.defCls(History, {
  @alias vm.Process;
  @alias vm.Kernel;
  @alias vm.Pid;

  @const PID_HISTORY = @_'history';

  @def start([Tuple], {
    history_pid = @native Kernel.spawn_link(@_'History', @_'start_history', [], {});
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
  @alias vm.Pid;

  @const VSN = '0.0.0';
  @const PREFIX = 'ia(';

  @def start({
    status = History.start();
    UnitTests.start();

    pid = Kernel.spawn(@_'CompilerMain', @_'start_interactive_anna');
    supervise(cast(pid, Pid));
  });

  @def supervise({Pid: pid}, [Atom], {
    Kernel.monitor(pid);
    Kernel.receive(@fn {
      ([{Tuple: status}] => {
        @native IO.inspect(status);
      });
    });
    start();
  });

  @def start_interactive_anna([Atom], {
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
    Kernel.stop();
    @_'nil';
  });

  // backspace
  @def handle_input({Int: 127, String: current_string}, [String], {
    clear_prompt(current_string);
    len = Str.length(current_string);
    len = Kernel.subtract(len, 1);
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
    all_tests_pid = Kernel.spawn_link(@_'UnitTests', @_'start_tests_store', cast([], Tuple), {});
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
class Code {
  public static function defineCode(): Atom {
    Classes.define(Atom.create('Kernel'), Kernel);
    Classes.define(Atom.create('CompilerMain'), CompilerMain);
    Classes.define(Atom.create('History'), History);
    Classes.define(Atom.create('Str'), Str);
    Classes.define(Atom.create('System'), System);
    Classes.define(Atom.create('CommandHandler'), CommandHandler);
    Classes.define(Atom.create('File'), File);
    Classes.define(Atom.create('UnitTests'), UnitTests);
    Classes.define(Atom.create('AnnaCompiler'), AnnaCompiler);
    Classes.define(Atom.create('JSON'), JSON);
    Classes.define(Atom.create('EEnum'), DefaultEnum);
    Classes.define(Atom.create('DefaultEnum'), DefaultEnum);

    return Atom.create('ok');
  }
}
