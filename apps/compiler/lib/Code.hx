package ;
import util.StringUtil;
import lang.AtomSupport;
import vm.Classes;
import vm.Pid;
import vm.Port;
import IO;
import vm.Function;
import CPPCLIInput;
@:build(lang.macros.AnnaLang.init())
//@:build(lang.macros.AnnaLang.defmodule(Str, {
//  @alias util.StringUtil;
//
//  @def concat({String: lhs, String: rhs}, [String], {
//    @native StringUtil.concat(lhs, rhs);
//  });
//
//  @def from_char_code({Int: char_code}, [String], {
//    @native StringUtil.fromCharCode(char_code);
//  });
//
//  @def substring({String: string, Int: start, Int: end}, [String], {
//    @native StringUtil.substring(string, start, end);
//  });
//
//  @def length({String: string}, [Int], {
//    @native StringUtil.length(string);
//  });
//
//  @def rpad({String: string, String: c_string, Int: length}, [String], {
//    @native StringUtil.rpad(string, c_string, length);
//  });
//
//  @def string_to_int({String: s}, [Int], {
//    @native Std.int(s);
//  });
//
//  @def random({Int: length}, [String], {
//    @native StringUtil.random(length);
//  });
//
//  @def nameify({String: str}, [String], {
//    @native StringUtil.nameify(str);
//  });
//
//  @def ends_with({String: str, String: other_str}, [Atom], {
//    @native StringUtil.endsWith(str, other_str);
//  });
//
//  @def remove_whitespace({String: str}, [String], {
//    @native StringUtil.removeWhitespace(str);
//  });
//}))
//@:build(lang.macros.AnnaLang.defmodule(Kernel, {
//  @alias vm.Pid;
//  @alias vm.NativeKernel;
//  @alias vm.Function;
//  @alias vm.Process;
//
//  @def stop({
//    @native NativeKernel.stop();
//  });
//
//  @def flush([Atom], {
//    data = receive(@fn {
//        [{Tuple: result}] => {
//        result;
//      };
//    });
//    @_'ok';
//  });
//
//  @def receive({Function: fun}, [Dynamic], {
//    @native NativeKernel.receive(fun);
//  });
//
//  @def receive({Function: fun, Int: timeout}, [Dynamic], {
//    @native NativeKernel.receive(fun, timeout);
//  });
//
//  @def send({Pid: pid, Tuple: value}, [Atom], {
//    @native NativeKernel.send(pid, value);
//    @_'ok';
//  });
//
//  @def send({Pid: pid, Atom: value}, [Atom], {
//    @native NativeKernel.send(pid, value);
//    @_'ok';
//  });
//
//  @def send({Pid: pid, MMap: value}, [Atom], {
//    @native NativeKernel.send(pid, value);
//    @_'ok';
//  });
//
//  @def sleep({Int: milliseconds}, [Atom], {
//    @native Process.sleep(milliseconds);
//  });
//
//  @def self([Pid], {
//    @native vm.Process.self();
//  });
//
//  @def pid_info([Tuple], {
//    dict = @native vm.Process.getDictionary();
//    [@_'ok', [@_'dictionary' => dict]];
//  });
//
//  @def monitor({Pid: pid}, [Atom], {
//    @native NativeKernel.monitor(pid);
//  });
//
//  @def demonitor({Pid: pid}, [Atom], {
//    @native NativeKernel.demonitor(pid);
//  });
//
//  @def spawn({Atom: module, Atom: func}, [Pid], {
//    @native NativeKernel.spawn(module, func, @tuple[], {});
//  });
//
//  @def spawn({Function: fun}, [Pid], {
//    @native NativeKernel.spawnFn(fun, {});
//  });
//
//  @def spawn({Atom: module, Atom: func, Tuple: types, LList: args}, [Pid], {
//    @native NativeKernel.spawn(module, func, types, args);
//  });
//
//  @def spawn_link({Function: fun}, [Pid], {
//    @native NativeKernel.spawn_linkFn(fun, {});
//  });
//
//  @def spawn_link({Atom: module, Atom: func}, [Pid], {
//    @native NativeKernel.spawn_link(module, func, @tuple[], {});
//  });
//
//  @def spawn_link({Atom: module, Atom: func, Tuple: types, LList: args}, [Pid], {
//    @native NativeKernel.spawn_link(module, func, types, args);
//  });
//
//  @def add({Float: a, Float: b}, [Float], {
//    @native NativeKernel.add(a, b);
//  });
//
//  @def subtract({Float: a, Float: b}, [Float], {
//    @native NativeKernel.subtract(a, b);
//  });
//
//  @def same({Dynamic: a, Dynamic: b}, [Atom], {
//    @native NativeKernel.same(a, b);
//  });
//
//  @def equal({Dynamic: a, Dynamic: b}, [Atom], {
//    @native NativeKernel.equal(a, b);
//  });
//
//  @def exit({Pid: pid}, [Atom], {
//    @native NativeKernel.exit(pid);
//  });
//
//  @def crash({Pid: pid}, [Atom], {
//    @native NativeKernel.crash(pid);
//  });
//
//  @def register_pid({Pid: pid, Atom: name}, [Atom], {
//    @native Process.registerPid(pid, name);
//  });
//
//  @def get_pid_by_name({Atom: name}, [Pid], {
//    @native Process.getPidByName(name);
//  });
//
//  @def apply({Function: fun, LList: args}, [Dynamic], {
//    @native NativeKernel.apply(self(), fun, args);
//  });
//
//  @def apply({Atom: module, Atom: fun, Tuple: types, LList: args}, [Dynamic], {
//    @native NativeKernel.applyMFA(self(), module, fun, types, args);
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(System, {
//  @def print({String: str}, [Atom], {
//    @native IO.print(str);
//  });
//
//  @def print({Int: str}, [Atom], {
//    @native IO.print(str);
//  });
//
//  @def print({Float: str}, [Atom], {
//    @native IO.print(str);
//  });
//
//  @def println({String: str}, [Atom], {
//    @native IO.println(str);
//  });
//
//  @def println({Int: str}, [Atom], {
//    @native IO.println(str);
//  });
//
//  @def println({Float: str}, [Atom], {
//    @native IO.println(str);
//  });
//
//  @def println({Atom: str}, [Atom], {
//    @native IO.println(str);
//  });
//
//  @def println({Tuple: str}, [Atom], {
//    @native IO.inspect(str);
//  });
//
//  @def println({Dynamic: d}, [Atom], {
//    @native IO.println(d);
//  });
//
//  @def set_cwd({String: str}, [Tuple], {
//    @native Sys.setCwd(str);
//    [@_'ok', str];
//  });
//
//  @def get_cwd([Tuple], {
//    cwd = @native Sys.getCwd();
//    [@_'ok', cwd];
//  });
//}))
//@:build(lang.macros.AnnaLang.defmodule(CommandHandler, {
//  @alias vm.NativeKernel;
//  @const PROJECT_SRC_PATH = 'project/';
//
//  @def process_command({String: 'exit'}, [Atom], {
//    System.println('exiting...');
//    @native NativeKernel.stop();
//    @_'exit';
//  });
//
//  @def process_command({String: 'r'}, [Atom], {
//    @native NativeKernel.recompile();
//    @native NativeKernel.stop();
//    @_'exit';
//  });
//
//  @def process_command({String: 'cb'}, [Atom], {
//    AppCode.compile('apps/bootstrap/boot_main.anna');
//    @_'ok';
//  });
//
//  @def process_command({String: 'v ' => number}, [Atom], {
//    index = Str.string_to_int(number);
//    index = Kernel.subtract(index, 1);
//    command = History.get(cast(index, Int));
//    System.println(command);
//    @_'ok';
//  });
//
////  @def process_command({String: 'build'}, [Atom], {
////    System.set_cwd(PROJECT_SRC_PATH);
////    System.println('building project');
////    [@_'ok', cwd] = System.get_cwd();
////    System.println(cast(cwd, String));
////    AnnaCompiler.build_project();
////    System.set_cwd('..');
////    @_'ok';
////  });
//
//  @def process_command({String: 't'}, [Atom], {
//    History.push('t');
//    Kernel.spawn(@fn {
//        [{}] => {
//        UnitTests.add_test(@_'StringTest');
//        UnitTests.add_test(@_'NumberTest');
//        UnitTests.add_test(@_'AtomTest');
//        UnitTests.add_test(@_'TupleTest');
//        UnitTests.add_test(@_'LListTest');
//        UnitTests.add_test(@_'MMapTest');
//        UnitTests.add_test(@_'KeywordTest');
//        UnitTests.add_test(@_'ModuleFunctionTest');
//        UnitTests.add_test(@_'CustomTypesTest');
//
//        UnitTests.run_tests();
//      }
//    });
//    @_'ok';
//  });
//
//  @def process_command({String: ''}, [Atom], {
//    @_'ok';
//  });
//
//  @def process_command({String: cmd}, [Atom], {
//    History.push(cmd);
//    result = Repl.eval(cmd);
//    handle_result(result);
//    @_'ok';
//  });
//
//  @def handle_result({Tuple: [@_'ok', @_'continuation']}, [Atom], {
//    @_'continuation';
//  });
//
//  @def handle_result({Tuple: _}, [Atom], {
//    @_'ok';
//  });
//}))
//@:build(lang.macros.AnnaLang.defapi(EEnum, {
//  @def all({LList: list, Function: callback}, [Atom]);
//  @def all({MMap: map, Function: callback}, [Atom]);
//  @def reduce({LList: list, LList: acc, Function: callback}, [List]);
//}))
//@:build(lang.macros.AnnaLang.defmodule(DefaultEnum, {
//  @alias vm.Function;
//  @impl EEnum;
//
//  // all LList
//  // ---------------------------------------------------------
//  @def all({LList: {}, Function: _}, [Atom], {
//    @_'true';
//  });
//
//  @def all({LList: {head | rest;}, Function: callback}, [Atom], {
//    result = callback(cast(head, Dynamic));
//    is_all(cast(result, Atom), cast(rest, LList), callback);
//  });
//
//  @def is_all({Atom: @_'true', LList: list, Function: callback}, [Atom], {
//    all(list, callback);
//  });
//
//  @def is_all({Atom: _, LList: _, Function: _}, [Atom], {
//    @_'false';
//  });
//
//  //======================================================
//  // all MMap
//  // ---------------------------------------------------------
//  @def all({MMap: map, Function: callback}, [Atom], {
//    keys = @native MMap.keys(map);
//    iterate_keys(keys, map, callback);
//  });
//
//  @def iterate_keys({LList: {}, MMap: _, Function: _}, [Atom], {
//    @_'true';
//  });
//
//  @def iterate_keys({LList: {key | rest;}, MMap: map, Function: callback}, [Atom], {
//    value = @native MMap.get(map, key);
//    result = callback(cast(value, Dynamic));
//    is_all(cast(result, Atom), cast(rest, LList), map, callback);
//  });
//
//  @def is_all({Atom: @_'true', LList: keys, MMap: map, Function: callback}, [Atom], {
//    iterate_keys(keys, map, callback);
//  });
//
//  @def is_all({Atom: _, LList: _, MMap: map, Function: _}, [Atom], {
//    @_'false';
//  });
//  //======================================================
//
//  // reduce
//  // --------------------------------------------------------
//  @def reduce({LList: {}, LList: acc, Function: _}, [LList], {
//    acc;
//  });
//
//  @def reduce({LList: {head | rest;}, LList: acc, Function: callback}, [LList], {
//    result = callback(cast(head, LList), acc);
//    reduce(cast(rest, LList), acc, callback);
//  });
//  //==========================================================
//}))
//@:build(lang.macros.AnnaLang.set_iface(EEnum, DefaultEnum))
//
//@:build(lang.macros.AnnaLang.defmodule(Repl, {
//  @alias vm.Lang;
//
//  @def eval({String: text}, [Tuple], {
//    result = @native Lang.eval(text);
//    handle_result(cast(result, Dynamic));
//  });
//
//  @def handle_result({Dynamic: [@_'ok', @_'continuation']}, [Tuple], {
//    [@_'ok', @_'continuation'];
//  });
//
//  @def handle_result({Dynamic: [@_'error', message]}, [Tuple], {
//    [@_'error', message];
//  });
//
//  @def handle_result({Dynamic: result}, [Tuple], {
//    @native IO.inspect(result);
//    [@_'ok', result];
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(Assert, {
//  @alias vm.Pid;
//
//  @def assert({Atom: lhs, Atom: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    assert(result);
//  });
//
//  @def assert({Tuple: lhs, Tuple: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    assert(result);
//  });
//
//  @def assert({LList: lhs, LList: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    assert(result);
//  });
//
//  @def assert({MMap: lhs, MMap: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    assert(result);
//  });
//
//  @def assert({Keyword: lhs, Keyword: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    assert(result);
//  });
//
//  @def assert({String: lhs, String: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    assert(result);
//  });
//
//  @def assert({Int: lhs, Int: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    assert(result);
//  });
//
//  @def assert({Pid: lhs, Pid: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    assert(result);
//  });
//
//  @def refute({Atom: lhs, Atom: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    refute(result);
//  });
//
//  @def refute({Tuple: lhs, Tuple: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    refute(result);
//  });
//
//  @def refute({LList: lhs, LList: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    refute(result);
//  });
//
//  @def refute({MMap: lhs, MMap: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    refute(result);
//  });
//
//  @def refute({Keyword: lhs, Keyword: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    refute(result);
//  });
//
//  @def refute({String: lhs, String: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    refute(result);
//  });
//
//  @def refute({Int: lhs, Int: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    refute(result);
//  });
//
//  @def refute({Pid: lhs, Pid: rhs}, [Atom], {
//    result = Kernel.equal(cast(lhs, Dynamic), cast(rhs, Dynamic));
//    refute(result);
//  });
//
//  @def assert({Atom: @_'true'}, [Atom], {
//    record_status(@_'pass');
//    @_'ok';
//  });
//
//  @def assert({Atom: _}, [Atom], {
//    record_status(@_'fail');
//    @_'error';
//  });
//
//  @def refute({Atom: @_'false'}, [Atom], {
//    record_status(@_'pass');
//    @_'ok';
//  });
//
//  @def refute({Atom: _}, [Atom], {
//    record_status(@_'fail');
//    @_'error';
//  });
//
//  @def record_status({Atom: status}, [Atom], {
//    self = Kernel.self();
//    UnitTests.update_status(self, status);
//    ret_val = Kernel.receive(@fn {
//        [{Atom: msg}] => {
//        msg;
//      };
//    });
//    ret_val;
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(StringTest, {
//  @alias vm.Lang;
//
//  @def test_should_create_strings([Atom], {
//    Assert.assert('foo', 'foo');
//  });
//
//  @def test_should_create_strings_interp([Atom], {
//    result = @native Lang.eval('"foo"');
//    Assert.assert('foo', cast(result, String));
//  });
//
//  @def test_should_not_match_strings([Atom], {
//    Assert.refute('foo', 'bar');
//  });
//
//  @def test_should_pattern_match_assignment([Atom], {
//      'foo ' => bar = 'foo bar';
//    Assert.assert('bar', cast(bar, String));
//
//      'foo ' => bar = 'foo bar';
//    Assert.refute('bar1', cast(bar, String));
//  });
//
//  @def test_should_pattern_match_assignment_interp([Atom], {
//    @native Lang.eval("'foo ' => bar = 'foo bar';
//    Assert.assert('bar', cast(bar, String));");
//
//    @native Lang.eval("'foo ' => bar = 'foo bar';
//    Assert.refute('bar1', cast(bar, String));");
//  });
//
//  @def test_should_pattern_match_function_string([Atom], {
//    match('foo bar');
//  });
//
//  @def test_should_match_function_head_strings([Atom], {
//    match('foo', 'bar');
//  });
//
//  @def test_should_match_function_head_strings_interp([Atom], {
//    result = @native Lang.eval('"bar"');
//    match('foo', cast(result, String));
//  });
//
//  @def match({String: 'foo', String: 'bar'}, [Atom], {
//    Assert.assert(@_'true');
//  });
//
//  @def match({String: _, String: _}, [Atom], {
//    Assert.assert(@_'false');
//  });
//
//  @def match({String: 'foo ' => bar}, [Atom], {
//    Assert.assert('bar', bar);
//  });
//
//  @def match({String: _}, [Atom], {
//    Assert.assert(@_'false');
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(NumberTest, {
//  @alias vm.Lang;
//
//  @def test_should_create_ints([Atom], {
//    Assert.assert(123, 123);
//  });
//
//  @def test_should_create_ints_interp([Atom], {
//    result = @native Lang.eval('4738');
//    Assert.assert(4738, cast(result, Number));
//  });
//
//  @def test_should_not_match_ints([Atom], {
//    Assert.refute(321, 123);
//  });
//
//  @def test_should_match_function_head_ints([Atom], {
//    match(123, 456);
//  });
//
//  @def test_should_match_function_head_ints_interp([Atom], {
//    result = @native Lang.eval('456');
//    match(123, cast(result, Number));
//  });
//
//  @def test_should_create_floats([Atom], {
//    Assert.assert(43.3245, 43.3245);
//  });
//
//  @def test_should_create_floats_interp([Atom], {
//    result = @native Lang.eval('43.3245');
//    Assert.assert(43.3245, cast(result, Number));
//  });
//
//  @def test_should_not_match_floats([Atom], {
//    Assert.refute(43.3245, 293.2094);
//  });
//
//  @def test_should_match_function_head_floats([Atom], {
//    match(43.3245, 89435.349);
//  });
//
//  @def test_should_match_function_head_floats_interp([Atom], {
//    result = @native Lang.eval('89435.349');
//    match(43.3245, cast(result, Number));
//  });
//
//  @def match({Float: 43.3245, Float: 89435.349}, [Atom], {
//    Assert.assert(@_'true');
//  });
//
//  @def match({Int: 123, Int: 456}, [Atom], {
//    Assert.assert(@_'true');
//  });
//
//  @def match({Float: 43.3245, Float: 89435.349}, [Atom], {
//    Assert.assert(@_'true');
//  });
//
//  @def match({Float: _, Float: _}, [Atom], {
//    Assert.assert(@_'false');
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(AtomTest, {
//  @alias vm.Lang;
//
//  @def test_should_create_atoms([Atom], {
//    Assert.assert(@_'ok', @_'ok');
//  });
//
//  @def test_should_not_match_atoms([Atom], {
//    Assert.refute(@_'ok', @_'fail');
//  });
//
//  @def test_should_create_atoms_interp([Atom], {
//    result = @native Lang.eval('@_"ok"');
//    Assert.assert(@_'ok', cast(result, Atom));
//  });
//
//  @def test_should_match_function_head_atoms([Atom], {
//    match(@_'ok', @_'good');
//  });
//
//  @def test_should_match_function_head_atoms_interp([Atom], {
//    result = @native Lang.eval("@_'good'");
//    match(@_'ok', cast(result, Atom));
//  });
//
//  @def match({Atom: @_'ok', Atom: @_'good'}, [Atom], {
//    Assert.assert(@_'true');
//  });
//
//  @def match({Atom: _, Atom: _}, [Atom], {
//    Assert.assert(@_'false');
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(TupleTest, {
//  @alias vm.Lang;
//
//  @def test_should_create_tuple_with_all_constant_elements([Atom], {
//    Assert.assert([@_'ok', 'message'], [@_'ok', 'message']);
//  });
//
//  @def test_should_create_tuple_with_all_constant_elements_interp([Atom], {
//    result = @native Lang.eval("[@_'ok', 'message']");
//    Assert.assert([@_'ok', 'message'], cast(result, Tuple));
//  });
//
//  @def test_should_create_tuple_with_all_variable_elements([Atom], {
//    status = @_'ok';
//    message = 'message';
//    Assert.assert([@_'ok', 'message'], [status, message]);
//  });
//
//  @def test_should_create_tuple_with_all_variable_elements_interp([Atom], {
//    result = @native Lang.eval("status = @_'ok'; message = 'message'; [status, message]");
//    Assert.assert([@_'ok', 'message'], cast(result, Tuple));
//  });
//
//  @def test_should_create_tuple_within_a_tuple([Atom], {
//    status = @_'ok';
//    Assert.assert([@_'ok', [@_'error', 'complete']], [status, [@_'error', 'complete']]);
//  });
//
//  @def test_should_create_tuple_within_a_tuple_interp([Atom], {
//    result = @native Lang.eval("status = @_'ok'; [status, [@_'error', 'complete']]");
//    Assert.assert([@_'ok', [@_'error', 'complete']], cast(result, Tuple));
//  });
//
//  @def test_should_match_tuple_on_function_head([Atom], {
//    match([@_'ok', [@_'error', 'complete']]);
//  });
//
//  @def test_should_match_tuple_on_function_head_interp([Atom], {
//    result = @native Lang.eval("TupleTest.match([@_'eval', [@_'error', 'complete']]);");
//    Assert.assert(cast(result, Atom));
//  });
//
////  @def test_should_create_tuple_with_function_calls_for_elements([Atom], {
////    result = [get_ok(), get_error(), get_complete()];
////    match([@_'ok', @_'error', 'complete'], result);
////  });
//
//  @def match({Tuple: [@_'ok', [@_'error', 'complete']]}, [Atom], {
//    Assert.assert(@_'true');
//  });
//
//  @def match({Tuple: [@_'eval', [@_'error', 'complete']]}, [Atom], {
//    @_'true';
//  });
//
//  @def match({Tuple: _}, [Atom], {
//    Assert.assert(@_'false');
//  });
//
//  @def get_ok([Atom], {
//    @_'ok';
//  });
//
//  @def get_error([Atom], {
//    @_'error';
//  });
//
//  @def get_complete([String], {
//    'complete';
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(LListTest, {
//  @alias vm.Lang;
//
//  @def test_should_create_llist_with_all_constant_elements([Atom], {
//    Assert.assert({@_'ok'; 'message';}, {@_'ok'; 'message';});
//  });
//
//  @def test_should_create_llist_with_all_constant_elements_interp([Atom], {
//    result = @native Lang.eval("{@_'ok'; 'message';}");
//    Assert.assert({@_'ok'; 'message';}, cast(result, LList));
//  });
//
//  @def test_should_create_llist_with_all_variable_elements([Atom], {
//    status = @_'ok';
//    message = 'message';
//    Assert.assert({@_'ok'; 'message';}, {status; message;});
//  });
//
//  @def test_should_create_llist_with_all_variable_elements_interp([Atom], {
//    result = @native Lang.eval("status = @_'ok'; message = 'message'; {status; message;}");
//    Assert.assert({@_'ok'; 'message';}, cast(result, LList));
//  });
//
//  @def test_should_create_llist_within_llist([Atom], {
//    Assert.assert({@_'ok'; {"nice"; "little"; ["list"];}}, {@_'ok'; {"nice"; "little"; ["list"];}});
//  });
//
//  @def test_should_create_llist_within_llist_interp([Atom], {
//    result = @native Lang.eval("{@_'ok'; {'nice'; 'little'; ['list'];}}");
//    Assert.assert({@_'ok'; {"nice"; "little"; ["list"];}}, cast(result, LList));
//  });
//
//  @def test_should_assign_head_and_tail([Atom], {
//    ({head | tail;}) = {1; 2; 3; 4;};
//    Assert.assert(1, cast(head, Int));
//    Assert.assert({2; 3; 4;}, cast(tail, LList));
//  });
//
//  @def test_should_assign_head_and_tail_interp([Atom], {
//    @native Lang.eval('({head | tail;}) = {1; 2; 3; 4;}; Assert.assert(1, cast(head, Int));
//    Assert.assert({2; 3; 4;}, cast(tail, LList));');
//  });
//
//  @def test_should_assign_to_individual_elements([Atom], {
//    ({one; two; three; four;}) = {1; 2; 3; 4;};
//    Assert.assert(1, cast(one, Int));
//    Assert.assert(2, cast(two, Int));
//    Assert.assert(3, cast(three, Int));
//    Assert.assert(4, cast(four, Int));
//  });
//
//  @def test_should_assign_to_individual_elements_interp([Atom], {
//    @native Lang.eval('({one; two; three; four;}) = {1; 2; 3; 4;};
//    Assert.assert(1, cast(one, Int));
//    Assert.assert(2, cast(two, Int));
//    Assert.assert(3, cast(three, Int));
//    Assert.assert(4, cast(four, Int));');
//  });
//
//  @def test_function_pattern_match_llist_with_head_and_tail([Atom], {
//    match({1; 2; 3; 4;});
//  });
//
//  @def test_function_pattern_match_llist_with_head_and_tail_interp([Atom], {
//    @native Lang.eval('LListTest.match({1; 2; 3; 4;});');
//  });
//
//  @def test_should_pattern_match_function_elements([Atom], {
//    match({1; 2; 3; 4; 5;});
//  });
//
//  @def test_should_pattern_match_function_elements_interp([Atom], {
//    @native Lang.eval('LListTest.match({1; 2; 3; 4; 5;})');
//  });
//
//  @def test_should_create_list_with_atoms([Atom], {
//    Assert.assert({@_'ok'; @_'error';}, {@_'ok'; @_'error';});
//  });
//
//  @def test_should_create_list_with_atoms_interp([Atom], {
//    @native Lang.eval("Assert.assert({@_'ok'; @_'error';}, {@_'ok'; @_'error';});");
//  });
//
//  @def match({LList: {a; b; c; d; e;}}, [Atom], {
//    Assert.assert(1, cast(a, Int));
//    Assert.assert(2, cast(b, Int));
//    Assert.assert(3, cast(c, Int));
//    Assert.assert(4, cast(d, Int));
//    Assert.assert(5, cast(e, Int));
//  });
//
//  @def match({LList: {head | tail;}}, [Atom], {
//    Assert.assert(1, cast(head, Int));
//    Assert.assert({2; 3; 4;}, cast(tail, LList));
//  });
//
//  @def match({LList: _}, [Atom], {
//    Assert.assert(@_'false');
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(MMapTest, {
//  @alias vm.Lang;
//
//  @def test_should_create_constant_map([Atom], {
//    Assert.assert(['foo' => 'bar'], ['foo' => 'bar']);
//  });
//
//  @def test_should_create_constant_map_interp([Atom], {
//    result = @native Lang.eval("['foo' => 'bar']");
//    Assert.assert(['foo' => 'bar'], cast(result, MMap));
//  });
//
//  @def test_should_create_map_with_variable_value([Atom], {
//    bar = 'bar';
//    Assert.assert(['foo' => 'bar'], ['foo' => bar]);
//  });
//
//  @def test_should_create_map_with_variable_value_interp([Atom], {
//    @native Lang.eval("bar = 'bar'; Assert.assert(['foo' => 'bar'], ['foo' => bar]);");
//  });
//
//  @def test_should_create_map_with_variable_key([Atom], {
//    bar = 'foo';
//    Assert.assert(['foo' => 'bar'], [bar => 'bar']);
//  });
//
//  @def test_should_create_map_with_variable_key_interp([Atom], {
//    @native Lang.eval("foo = 'foo'; Assert.assert(['foo' => 'bar'], [foo => 'bar']);");
//  });
//
//  @def test_should_create_map_with_variable_key_and_variable_value([Atom], {
//    foo = 'foo';
//    bar = 'bar';
//    Assert.assert(['foo' => 'bar'], [foo => bar]);
//  });
//
//  @def test_should_create_map_with_variable_key_and_variable_value_interp([Atom], {
//    @native Lang.eval("foo = 'foo';
//    bar = 'bar';
//    Assert.assert(['foo' => 'bar'], [foo => bar]);");
//  });
//
//  @def test_should_create_map_with_multiple_types([Atom], {
//    foo = 'foo';
//    bar = @_'bar';
//    Assert.assert(['baz' => {'foo';}, 'cat' => [@_'bar']], ['baz' => {foo;}, 'cat' => [bar]]);
//  });
//
//  @def test_should_create_map_with_multiple_types_interp([Atom], {
//    @native Lang.eval("foo = 'foo';
//    bar = @_'bar';
//    Assert.assert(['baz' => {'foo';}, 'cat' => [@_'bar']], ['baz' => {foo;}, 'cat' => [bar]]);");
//  });
//
//  @def test_should_assign_map_values_to_pattern_match([Atom], {
//    ['foo' => bar, 'baz' => 'cat'] = ['foo' => 'bar', 'baz' => 'cat'];
//    Assert.assert('bar', cast(bar, String));
//  });
//
//  @def test_should_assign_map_values_to_pattern_match_interp([Atom], {
//    @native Lang.eval("['foo' => bar, 'baz' => 'cat'] = ['foo' => 'bar', 'baz' => 'cat'];
//    Assert.assert('bar', cast(bar, String));");
//  });
//
//  @def test_should_match_on_map_with_mismatched_number_of_keys([Atom], {
//    ['foo' => bar] = ['foo' => 'bar', 'baz' => 'cat'];
//    Assert.assert('bar', cast(bar, String));
//  });
//
//  @def test_should_match_on_map_with_mismatched_number_of_keys_interp([Atom], {
//    @native Lang.eval("['foo' => bar] = ['foo' => 'bar', 'baz' => 'cat'];
//    Assert.assert('bar', cast(bar, String));");
//  });
//
//  @def test_should_create_map_with_atom_keys([Atom], {
//    foo = 'foo';
//    bar = 'bar';
//    Assert.assert([@_'success' => 'foo', @_'fail' => 'bar'], [@_'success' => foo, @_'fail' => bar]);
//  });
//
//  @def test_should_create_map_with_atom_keys_interp([Atom], {
//    @native Lang.eval("foo = 'foo';
//    bar = 'bar';
//    Assert.assert([@_'success' => 'foo', @_'fail' => 'bar'], [@_'success' => foo, @_'fail' => bar]);");
//  });
//
//  @def test_should_create_map_with_atom_keys_and_atom_values([Atom], {
//    foo = @_'foo';
//    bar = @_'bar';
//    Assert.assert([@_'success' => @_'foo', @_'fail' => @_'bar'], [@_'success' => foo, @_'fail' => bar]);
//  });
//
//  @def test_should_create_map_with_atom_keys_and_atom_values_interp([Atom], {
//    @native Lang.eval("foo = @_'foo';
//    bar = @_'bar';
//    Assert.assert([@_'success' => @_'foo', @_'fail' => @_'bar'], [@_'success' => foo, @_'fail' => bar]);");
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(KeywordTest, {
//  @alias vm.Lang;
//
//  @def test_should_create_static_keyword([Atom], {
//    Assert.refute({beanus: 'bear'}, {ellie: 'bear'});
//    Assert.assert({ellie: 'bear'}, {ellie: 'bear'});
//  });
//
//  @def test_should_create_static_keyword_interp([Atom], {
//    @native Lang.eval("Assert.refute({beanus: 'bear'}, {ellie: 'bear'});
//    Assert.assert({ellie: 'bear'}, {ellie: 'bear'});");
//  });
//
//  @def test_should_create_keyword_with_variable_values([Atom], {
//    bear = 'bear';
//    Assert.refute({beanus: 'bear'}, {ellie: bear});
//    Assert.assert({ellie: 'bear'}, {ellie: bear});
//  });
//
//  @def test_should_create_keyword_with_variable_values_interp([Atom], {
//    @native Lang.eval("bear = 'bear';
//    Assert.refute({beanus: 'bear'}, {ellie: bear});
//    Assert.assert({ellie: 'bear'}, {ellie: bear});");
//  });
//
//  @def test_should_create_keyword_with_complex_values([Atom], {
//    beanus = 'be-anus';
//    Assert.refute({ellie: 'beanus', beanus: {@_'cat'; 'strange';}}, {ellie: beanus, beanus: {@_'cat'; 'strange';}});
//    beanus = 'beanus';
//    Assert.assert({ellie: 'beanus', beanus: {@_'cat'; 'strange';}}, {ellie: beanus, beanus: {@_'cat'; 'strange';}});
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(ModuleFunctionTest, {
//  @alias vm.Function;
//  @alias vm.Lang;
//
//  @def test_should_invoke_function_with_static_arg([Atom], {
//    single_arg(@_'true');
//  });
//
//  @def test_should_invoke_function_with_static_arg_interp([Atom], {
//    @native Lang.eval("ModuleFunctionTest.single_arg(@_'true');");
//  });
//
//  @def test_should_invoke_public_functions_with_variables([Atom], {
//    number = 4;
//    result = Kernel.add(1, number);
//    Assert.assert(5, result);
//  });
//
//  @def test_should_invoke_public_functions_with_variables_interp([Atom], {
//    @native Lang.eval("number = 4;
//    result = Kernel.add(7, number);
//    Assert.assert(11, result);");
//  });
//
//  @def test_should_interpret_code_with_sharing_var_names_to_prevent_memory_exposure([Atom], {
//    @native Lang.eval("string = 'foo';
//    result = Str.concat(string, ' bar');
//    Assert.assert('foo bar', result);");
//  });
//
//  @def test_should_invoke_function_with_cast([Atom], {
//    ({val | _;}) = {'foo'; 'bar'; 'cat'; 'baz';};
//    result = Str.concat(cast(val, String), ' bar');
//    Assert.assert('foo bar', result);
//  });
//
//  @def test_should_invoke_function_with_cast_interp([Atom], {
//    @native Lang.eval("({val | _;}) = {'foo'; 'bar'; 'cat'; 'baz';};
//    result = Str.concat(cast(val, String), ' bar');
//    Assert.assert('foo bar', result);");
//  });
//
//  @def test_should_create_anonymous_function_with_no_args([Atom], {
//    fun = @fn {
//      [{}] => {
//        @_'true';
//      };
//    };
//    result = fun();
//    Assert.assert(cast(result, Atom));
//  });
//
//  @def test_should_create_anonymous_function_with_no_args_interp([Atom], {
//    @native Lang.eval("fun = @fn {
//      [{}] => {
//        @_'true';
//      };
//    };
//    result = fun();
//    Assert.assert(cast(result, Atom));");
//  });
//
//  @def test_should_create_anonymous_function_with_1_arg([Atom], {
//    fun = @fn {
//      [{Atom: status}] => {
//        status;
//      };
//    };
//    result = fun(@_'true');
//    Assert.assert(cast(result, Atom));
//
//    result = fun(@_'false');
//    Assert.refute(cast(result, Atom));
//  });
//
//  @def test_should_create_anonymous_function_with_1_arg_interp([Atom], {
//    @native Lang.eval("fun = @fn {
//      [{Atom: status}] => {
//        status;
//      };
//    };
//    result = fun(@_'true');
//    Assert.assert(cast(result, Atom));
//
//    result = fun(@_'false');
//    Assert.refute(cast(result, Atom));");
//  });
//
//  @def test_should_create_anonymous_function_with_2_args([Atom], {
//    fun = @fn {
//      [{Int: a, Int: b}] => {
//        Kernel.add(a, b);
//      };
//    };
//    result = fun(32, 563);
//    Assert.assert(595, cast(result, Int));
//    Assert.refute(532, cast(result, Int));
//  });
//
//  @def test_should_create_anonymous_function_with_2_args_interp([Atom], {
//    @native Lang.eval("fun = @fn {
//      [{Int: a, Int: b}] => {
//        Kernel.add(a, b);
//      };
//    };
//    result = fun(32, 563);
//    Assert.assert(595, cast(result, Int));
//    Assert.refute(532, cast(result, Int));");
//  });
//
//  @def test_should_interpret_function_string_and_assign_to_the_compiled_code_and_execute([Atom], {
//    fun_interp = @native Lang.eval("@fn {
//      [{Int: a, Int: b}] => {
//        Kernel.add(a, b);
//      };
//    };");
//    fun = cast(fun_interp, Function);
//    result = fun(32, 563);
//    Assert.assert(595, cast(result, Int));
//    Assert.refute(532, cast(result, Int));
//  });
//
//  @def test_should_pattern_match_individual_anonymous_function_heads([Atom], {
//    fun = @fn {
//      [{Atom: @_'ok'}] => {
//        @_'true';
//      };
//      [{Atom: @_'error'}] => {
//        @_'false';
//      };
//    };
//    result = fun(@_'ok');
//    Assert.assert(cast(result, Atom));
//    result = fun(@_'error');
//    Assert.refute(cast(result, Atom));
//  });
//
//  @def test_should_pattern_match_individual_anonymous_function_heads_interp([Atom], {
//    @native Lang.eval("fun = @fn {
//      [{Atom: @_'ok'}] => {
//        @_'true';
//      };
//      [{Atom: @_'error'}] => {
//        @_'false';
//      };
//    };
//    result = fun(@_'ok');
//    Assert.assert(cast(result, Atom));
//    result = fun(@_'error');
//    Assert.refute(cast(result, Atom));");
//  });
//
//  @def test_should_pattern_match_anonymous_function_with_catchall([Atom], {
//    fun = @fn {
//      [{Atom: @_'ok'}] => {
//        @_'true';
//      };
//      [{String: catch_all}] => {
//        @_'false';
//      };
//    };
//    result = fun(@_'ok');
//    Assert.assert(cast(result, Atom));
//    result = fun('foo');
//    Assert.refute(cast(result, Atom));
//  });
//
//  @def test_should_pattern_match_anonymous_function_with_overloaded_types([Atom], {
//    fun = @fn {
//      [{Atom: @_'ok'}] => {
//        @_'true';
//      };
//      [{String: catch_all}] => {
//        @_'false';
//      };
//    };
//    result = fun(@_'ok');
//    Assert.assert(cast(result, Atom));
//    result = fun('foo');
//    Assert.refute(cast(result, Atom));
//  });
//
//  @def test_should_pattern_match_function_head_with_catchall([Atom], {
//    result = handle_catch_all(@_'ok');
//    Assert.assert(cast(result, Atom));
//    result = handle_catch_all(cast(@_'face', Dynamic));
//    Assert.refute(cast(result, Atom));
//  });
//
//  @def handle_catch_all({Atom: @_'ok'}, [Atom], {
//    @_'true';
//  });
//
//  @def handle_catch_all({Dynamic: catch_all}, [Atom], {
//    @_'false';
//  });
//
//  @def test_should_create_new_module_interp([Atom], {
//    @native Lang.eval("
//    defmodule(Foo, {
//
//      @def new_func({Atom: @_'ok'}, [Atom], {
//        @_'true';
//      });
//
//      @def new_func({Atom: @_'error'}, [Atom], {
//        @_'false';
//      });
//
//    });
//
//    result = Foo.new_func(@_'error');
//    Assert.refute(result);
//    result = Foo.new_func(@_'ok');
//    Assert.assert(result);
//    ");
//  });
//
//  @def test_should_call_api_function([Atom], {
//    Assert.assert(FooApi.go(@_'true'));
//    Assert.refute(FooApi.go(@_'false'));
//  });
//
//  @def test_should_call_api_function_interp([Atom], {
//    @native Lang.eval("Assert.assert(FooApi.go(@_'true'));
//    Assert.refute(FooApi.go(@_'false'));");
//  });
//
//  @def test_should_create_new_api_interp([Atom], {
//    @native Lang.eval("defapi(MyApi, {
//      @def fun({Atom: arg}, [Atom]);
//    });
//    defmodule(MyApiImpl, {
//      @impl MyApi;
//
//      @def fun({Atom: arg}, [Atom], {
//        arg;
//      });
//    });
//    set_iface(MyApi, MyApiImpl);
//    result = MyApi.fun(@_'true');
//    ModuleFunctionTest.single_arg(result)");
//  });
//
//  @def test_should_call_native_functions([Atom], {
//    pid = @native vm.Process.self();
//    Assert.assert(pid, Kernel.self());
//  });
//
//  @def test_should_call_native_functions_interp([Atom], {
//    @native Lang.eval("pid = @native vm.Process.self();
//      Assert.assert(pid, Kernel.self());");
//  });
//
//  @def test_should_handle_message_passing([Atom], {
//    me = Kernel.self();
//    pid = Kernel.spawn(@fn {
//      [{}] => {
//        Kernel.send(me, @_'success');
//      };
//    });
//    result = Kernel.receive(@fn {
//      [{Atom: status}] => {
//        status;
//      };
//    });
//    Assert.assert(cast(result, Atom), @_'success');
//  });
//
//  @def test_should_handle_message_passing_interp([Atom], {
//    @native Lang.eval("
//      defmodule(TestDrive, {
//        @def test([String], {
//          me = Kernel.self();
//          pid = Kernel.spawn(@fn {
//            [{}] => {
//              Kernel.send(me, @_'success');
//            };
//          });
//          result = Kernel.receive(@fn {
//            [{Atom: status}] => {
//              status;
//            };
//          });
//          Assert.assert(cast(result, Atom), @_'success');
//        });
//      });
//    ");
//    @native Lang.eval('TestDrive.test()');
//  });
//
//  @def single_arg({Atom: status}, [Atom], {
//    Assert.refute(status, @_'false');
//    Assert.assert(status, @_'true');
//    @_'true';
//  });
//
//}))
//@:build(lang.macros.AnnaLang.deftype(SampleType, {
//  var name: String;
//  var age: Int;
//}))
//@:build(lang.macros.AnnaLang.deftype(SampleComposeType, {
//  var name: String;
//  var sample: SampleType;
//}))
//@:build(lang.macros.AnnaLang.defmodule(CustomTypesTest, {
//  @alias vm.Lang;
//  @def test_should_pass_type_to_function([Atom], {
//    sample = SampleType % {name: 'Ellie', age: 3};
//    pass_type(sample);
//  });
//
//  @def test_should_pass_type_to_function_interp([Atom], {
//    @native Lang.eval("sample = SampleType%{name: 'Stink', age: 3};
//      CustomTypesTest.pass_type(sample);");
//  });
//
//  @def test_should_get_type_value([Atom], {
//    sample = SampleType % {name: 'Benus', age: 30};
//    Assert.assert('Benus', sample.name);
//  });
//
//  @def test_should_get_type_value_interp([Atom], {
//    @native Lang.eval("sample = SampleType%{name: 'Benus', age: 30};
//      Assert.assert('Benus', sample.name);");
//  });
//
//  @def test_should_create_a_new_custom_type_when_updating_a_value([Atom], {
//    sample1 = SampleType % {name: 'Ellie', age: 3};
//    sample2 = SampleType.set(sample1, @_'name', 'bear');
//    Assert.assert('Ellie', sample1.name);
//    Assert.assert('bear', sample2.name);
//    Assert.refute(sample1.name, sample2.name);
//  });
//
//  @def test_should_create_a_new_custom_type_when_updating_a_value_interp([Atom], {
//    @native Lang.eval("
//    sample1 = SampleType%{name: 'Ellie', age: 3};
//    sample2 = SampleType.set(sample1, @_'name', 'bear');
//    Assert.assert('Ellie', sample1.name);
//    Assert.assert('bear', sample2.name);
//    Assert.refute(sample1.name, sample2.name);
//    ");
//  });
//
//  @def test_should_pattern_match_on_assignment([Atom], {
//    sample1 = SampleType % {name: 'Ellie', age: 3};
//    SampleType % {name: name, age: age} = sample1;
//    Assert.assert('Ellie', name);
//    Assert.assert(3, age);
//
//    sample2 = SampleType % {name: 'Bear', age: 5};
//    SampleType % {name: 'Bear', age: age} = sample2;
//    Assert.assert(5, age);
//  });
//
//  @def test_should_pattern_match_on_assignment_interp([Atom], {
//    @native Lang.eval("
//    sample1 = SampleType%{name: 'Ellie', age: 3};
//    SampleType%{name: name, age: age} = sample1;
//    Assert.assert('Ellie', name);
//    Assert.assert(3, age);
//
//    sample2 = SampleType%{name: 'Bear', age: 5};
//    SampleType%{name: 'Bear', age: age} = sample2;
//    Assert.assert(5, age);
//    ");
//  });
//
//  @def test_should_create_custom_type_with_variable_values([Atom], {
//    name = 'Ellie';
//    age = 3;
//    sample1 = SampleType % {name: name, age: age};
//    Assert.assert('Ellie', sample1.name);
//    Assert.assert(3, sample1.age);
//  });
//
//  @def test_should_create_custom_type_with_variable_values_interp([Atom], {
//    @native Lang.eval("
//    name = 'Ellie';
//    age = 3;
//    sample1 = SampleType%{name: name, age: age};
//    Assert.assert('Ellie', sample1.name);
//    Assert.assert(3, sample1.age);
//    ");
//  });
//
//  @def test_should_use_dot_operator_to_fetch_field_value([Atom], {
//    sample1 = SampleType % {name: 'Ellie', age: 3};
//    name = sample1.name;
//    age = sample1.age;
//    Assert.assert('Ellie', name);
//    Assert.assert(3, age);
//  });
//
//  @def test_should_use_dot_operator_to_fetch_field_value_interp([Atom], {
//    @native Lang.eval("
//    sample1 = SampleType%{name: 'Ellie', age: 3};
//    name = sample1.name;
//    age = sample1.age;
//    Assert.assert('Ellie', name);
//    Assert.assert(3, age);
//    ");
//  });
//
//  @def test_should_pattern_match_function_signature([Atom], {
//    sample1 = SampleType % {name: 'Ellie', age: 3};
//    match_signature(sample1);
//  });
//
//  @def test_should_pattern_match_function_signature_interp([Atom], {
//    @native Lang.eval("
//    sample1 = SampleType%{name: 'Ellie', age: 3};
//    CustomTypesTest.match_signature(sample1);
//    ");
//  });
//
//  @def test_should_handle_composable_types([Atom], {
//    obj = SampleComposeType % {name: 'foo', sample: SampleType % {name: 'bar', age: 43}};
//    sample = obj.sample;
//    Assert.assert('foo', obj.name);
//    Assert.assert('bar', sample.name);
//    Assert.assert(43, sample.age);
//  });
//
//  @def test_should_handle_composable_types_interp([Atom], {
//    @native Lang.eval("
//    obj = SampleComposeType%{name: 'foo', sample: SampleType%{name: 'bar', age: 43}};
//    sample = obj.sample;
//    Assert.assert('foo', obj.name);
//    Assert.assert('bar', sample.name);
//    Assert.assert(43, sample.age);
//    ");
//  });
//
//  @def test_should_define_custom_type_interp([Atom], {
//    @native Lang.eval("
//      deftype(Pets, {
//        var cow: String;
//        var bird: String;
//      });
//      pets = Pets%{cow: 'Beatrice', bird: 'Ally'};
//      Assert.assert('Beatrice', pets.cow);
//      Assert.assert('Ally', pets.bird);
//    ");
//  });
//
//  @def match_signature({SampleType: SampleType%{name: 'Ellie', age: age}}, [Atom], {
//    Assert.assert(3, age);
//  });
//
//  @def pass_type({SampleType: sample}, [Atom], {
//    Assert.assert(@_'true');
//  });
//}))
//@:build(lang.macros.AnnaLang.defapi(FooApi, {
//  @def go({Atom: arg}, [Atom]);
//}))
//@:build(lang.macros.AnnaLang.defmodule(FooImpl, {
//  @impl FooApi;
//
//  @def go({Atom: arg}, [Atom], {
//    arg;
//  });
//}))
//@:build(lang.macros.AnnaLang.set_iface(FooApi, FooImpl))
//@:build(lang.macros.AnnaLang.defmodule(History, {
//  @alias vm.Process;
//  @alias vm.NativeKernel;
//  @alias vm.Pid;
//
//  @const PID_HISTORY = @_'history';
//
//  @def start([Tuple], {
//    history_pid = @native NativeKernel.spawn_link(@_'History', @_'start_history', @tuple[], {});
//    Kernel.register_pid(history_pid, PID_HISTORY);
//
//    [@_'ok', history_pid];
//  });
//
//  @def start_history([Tuple], {
//    history_loop([1, {}, 0]);
//  });
//
//  @def history_loop({Tuple: history}, [Tuple], {
//    received = Kernel.receive(@fn {
//        [{Tuple: [@_'current_line', @_'inc']}] => {
//        [current_line, commands, scroll_pos] = history;
//        current_line = Kernel.add(cast(current_line, Int), 1);
//        [current_line, commands, scroll_pos];
//      };
//        [{Tuple: [@_'current_line', @_'get', pid]}] => {
//        [current_line, _, _] = history;
//        @native NativeKernel.send(pid, current_line);
//        history;
//      };
//        [{Tuple: [@_'scroll', @_'back', pid]}] => {
//        [current_line, commands, scroll_pos] = history;
//        scroll_pos = Kernel.subtract(cast(scroll_pos, Int), 1);
//        handle_history(cast(commands, LList), cast(pid, Pid), scroll_pos);
//        [current_line, commands, scroll_pos];
//      };
//        [{Tuple: [@_'scroll', @_'forward', pid]}] => {
//        [current_line, commands, scroll_pos] = history;
//        scroll_pos = Kernel.add(cast(scroll_pos, Int), 1);
//        handle_history(cast(commands, LList), cast(pid, Pid), scroll_pos);
//        [current_line, commands, scroll_pos];
//      };
//        [{Tuple: [@_'push', val]}, [Tuple]] => {
//        [current_line, commands, scroll_pos] = history;
//        commands = @native LList.add(commands, val);
//        scroll_pos = @native LList.length(commands);
//        [current_line, commands, scroll_pos];
//      };
//        [{Tuple: [@_'get', index, respond]}, [Tuple]] => {
//        [_, commands, _] = history;
//        value = @native LList.getAt(commands, index);
//        @native NativeKernel.send(cast(respond, Pid), cast(value, String));
//        history;
//      };
//    });
//    history_loop(cast(received, Tuple));
//  });
//
//  @def handle_history({LList: {}, Pid: pid, Int: _}, [Atom], {
//    @native NativeKernel.send(pid, '');
//  });
//
//  @def handle_history({LList: commands, Pid: pid, Int: scroll_pos}, [Atom], {
//    total_commands = @native LList.length(commands);
//    command = @native LList.getAt(commands, scroll_pos);
//    @native NativeKernel.send(pid, command);
//  });
//
//  @def increment_line([Atom], {
//    pid = Kernel.get_pid_by_name(PID_HISTORY);
//    Kernel.send(pid, [@_'current_line', @_'inc']);
//  });
//
//  @def get_counter([Int], {
//    pid = Kernel.get_pid_by_name(PID_HISTORY);
//    self = Kernel.self();
//    Kernel.send(pid, [@_'current_line', @_'get', self]);
//    Kernel.receive(@fn {
//        [{Int: line}, [Int]] => {
//        line;
//      };
//    });
//  });
//
//  @def push({String: command}, [Atom], {
//    pid = Kernel.get_pid_by_name(PID_HISTORY);
//    Kernel.send(pid, [@_'push', command]);
//    @_'ok';
//  });
//
//  @def get({Int: index}, [String], {
//    pid = Kernel.get_pid_by_name(PID_HISTORY);
//    self = Kernel.self();
//    Kernel.send(pid, [@_'get', index, self]);
//    Kernel.receive(@fn {
//        [{String: command}, [String]] => {
//        command;
//      };
//    });
//  });
//
//  @def back([String], {
//    pid = Kernel.get_pid_by_name(PID_HISTORY);
//    self = Kernel.self();
//    Kernel.send(pid, [@_'scroll', @_'back', self]);
//    Kernel.receive(@fn {
//        [{String: command}, [String]] => {
//        command;
//      };
//    });
//  });
//
//  @def forward([String], {
//    pid = Kernel.get_pid_by_name(PID_HISTORY);
//    self = Kernel.self();
//    Kernel.send(pid, [@_'scroll', @_'forward', self]);
//    Kernel.receive(@fn {
//        [{String: command}, [String]] => {
//        command;
//      };
//    });
//  });
//}))
//@:build(lang.macros.AnnaLang.defmodule(CompilerMain, {
//  @alias vm.Process;
//  @alias vm.Pid;
//  @alias vm.Port;
//  @alias vm.PortMan;
//
//  @const VSN = '0.0.0';
//  @const PREFIX = 'ia(';
//
//  @def start({
//    History.start();
//    UnitTests.start();
//
//    pid = Kernel.spawn(@_'CompilerMain', @_'start_interactive_anna');
//    supervise(cast(pid, Pid));
//  });
//
//  @def supervise({Pid: pid}, [Atom], {
//    Kernel.monitor(pid);
//    Kernel.receive(@fn {
//        [{Tuple: status}] => {
//        @native IO.inspect(status);
//      };
//    });
//    start();
//  });
//
//  @def start_interactive_anna([Atom], {
//    port = @native PortMan.create('CPPCLIInput');
//
//    welcome = Str.concat('Interactive Anna version ', VSN);
//    System.println(welcome);
//    prompt(port);
//  });
//
//  @def prompt({Port: port}, [Atom], {
//    prompt_string = get_prompt();
//    System.print(prompt_string);
//    collect_user_input(port, '', '');
//  });
//
//  @def get_prompt([String], {
//    counter = History.get_counter();
//    prefix = Str.concat(PREFIX, cast(counter, String));
//    Str.concat(prefix, ')> ');
//  });
//
//  @def read_input({Port: port}, [Int], {
//    @native PortMan.send(port, null);
//    Kernel.receive(@fn {
//        [{Tuple: [@_'ok', input]}] => {
//        input;
//      };
//    });
//  });
//
//  @def collect_user_input({Port: port, String: current_string, String: full_string}, [String], {
//    input = read_input(port);
//    current_string = handle_input(input, current_string, full_string, port);
//    collect_user_input(port, current_string, full_string);
//  });
//
//  @def handle_result({Atom: @_'ok', String: current_string}, [Atom], {
//    History.increment_line();
//    prompt_string = get_prompt();
//    System.print(prompt_string);
//    //prompt();
//    current_string;
//  });
//
//  @def handle_result({Atom: @_'continuation', String: current_string}, [String], {
//    continuation_prompt(current_string);
//  });
//
//  @def handle_result({Atom: @_'exit', String: _}, [String], {
//    @_'nil';
//  });
//
//  @def continuation_prompt({String: current_string}, [String], {
//    current_string;
//  });
//
//  // enter
//  @def handle_input({Int: 13, String: current_string, String: full_string, Port: _}, [String], {
//    System.println('');
//    current_string = Str.remove_whitespace(current_string);
//    result = CommandHandler.process_command(current_string);
//    handle_result(result, current_string);
//    '';
//  });
//
//  // ctrl+u
//  @def handle_input({Int: 21, String: current_string, String: full_string, Port: _}, [String], {
//    clear_prompt(current_string);
//    print_prompt('', full_string);
//    '';
//  });
//
//  // ctrl+d
//  @def handle_input({Int: 4, String: _, String: _, Port: port}, [String], {
//    System.println('');
//    System.println('exiting...');
//    Kernel.stop();
//    '';
//  });
//
//  // backspace
//  @def handle_input({Int: 127, String: current_string, String: full_string, Port: port}, [String], {
//    clear_prompt(current_string);
//    len = Str.length(current_string);
//    len = Kernel.subtract(len, 1);
//    current_string = Str.substring(current_string, 0, len);
//    print_prompt(current_string, full_string);
//    current_string;
//  });
//
//  // arrow keys
//  @def handle_input({Int: 27, String: current_string, String: full_string, Port: port}, [String], {
//    read_input(port);
//    input = read_input(port);
//    handle_arrow_input(input, current_string, full_string, port);
//  });
//
//  @def handle_input({Int: code, String: current_string, String: full_string, Port: port}, [String], {
//    str = Str.from_char_code(code);
//    str = Str.remove_whitespace(str);
//    System.print(str);
//    current_string = Str.concat(current_string, str);
//    current_string;
//  });
//
//  // up arrow
//  @def handle_arrow_input({Int: 65, String: current_string, String: full_string, Port: port}, [String], {
//    clear_prompt(current_string);
//    current_string = History.back();
//    print_prompt(current_string, full_string);
//    current_string;
//  });
//
//  // down arrow
//  @def handle_arrow_input({Int: 66, String: current_string, String: full_string, Port: port}, [String], {
//    clear_prompt(current_string);
//    current_string = History.forward();
//    print_prompt(current_string, full_string);
//    current_string;
//  });
//
//  @def clear_prompt({String: current_string}, {
//    str_len = Str.length(current_string);
//    str_len = Kernel.add(str_len, 20);
//    clear_string = Str.rpad('\r', ' ', str_len);
//    System.print(clear_string);
//  });
//
//  @def print_prompt({String: current_string, String: full_string}, {
//    str_prompt = get_prompt();
//    str_prompt = Str.concat(str_prompt, current_string);
//    str_prompt = Str.concat('\r', str_prompt);
//    str_prompt = Str.rpad(str_prompt, ' ', 7);
//    System.print(str_prompt);
//  });
//
//}))
//@:build(lang.macros.AnnaLang.defmodule(AppCode, {
//  @alias vm.Classes;
//  @alias vm.Lang;
//
//  @def get_modules([LList], {
//    @native Classes.getModules();
//  });
//
//  @def get_api({Atom: module}, [LList], {
//    @native Classes.getApiFunctions(module);
//  });
//
//  @def compile({String: file_path}, [Tuple], {
//    content = File.get_content(file_path);
//    @native Lang.eval(content);
//    [@_'ok', file_path];
//  });
//}))
//@:build(lang.macros.AnnaLang.defmodule(UnitTests, {
//  @alias vm.Process;
//  @alias vm.NativeKernel;
//  @alias vm.Classes;
//  @alias vm.Pid;
//
//  @const ALL_TESTS = @_'all_tests';
//  @const TEST_RESULTS = @_'test_results';
//  @const DEFAULT_RESULTS = [[], [], @_'false'];
//
//  @def start([Tuple], {
//    all_tests_pid = Kernel.spawn_link(@_'UnitTests', @_'start_tests_store', @tuple[], {});
//    Kernel.register_pid(all_tests_pid, ALL_TESTS);
//
//    test_results_pid = Kernel.spawn_link(@_'UnitTests', @_'start_test_results_store', @tuple[], {});
//    Kernel.register_pid(test_results_pid, TEST_RESULTS);
//
//    [@_'ok', all_tests_pid];
//  });
//
//  @def start_tests_store([LList], {
//    tests_store_loop({});
//  });
//
//  @def tests_store_loop({LList: all_tests}, [LList], {
//    received = Kernel.receive(@fn {
//        [{Tuple: [@_'store', test_module]}] => {
//        @native LList.add(all_tests, test_module);
//      };
//        [{Tuple: [@_'get', respond_pid]}] => {
//        @native NativeKernel.send(respond_pid, all_tests);
//        @native LList.empty();
//      };
//    });
//    tests_store_loop(cast(received, LList));
//  });
//
//  @def add_test({Atom: module}, [Atom], {
//    all_tests_pid = Kernel.get_pid_by_name(ALL_TESTS);
//    Kernel.send(all_tests_pid, [@_'store', module]);
//    @_'ok';
//  });
//
//  @def start_test_results_store([Tuple], {
//    test_results_store_loop(DEFAULT_RESULTS);
//  });
//
//  @def test_results_store_loop({Tuple: [all_tests, test_results, all_tests_registered]}, [Tuple], {
//    received = Kernel.receive(@fn {
//        [{Tuple: [@_'save', test_pid, test_name, module, func, status, payload]}] => {
//        test_results = @native MMap.put(test_results, test_pid, [test_name, module, func, status, payload]);
//        [all_tests, test_results, all_tests_registered];
//      };
//        [{Tuple: [@_'update_status', test_pid, new_status]}] => {
//        test_status = [test_name, module, func, ~new_status, payload] = @native MMap.get(test_results, test_pid);
//        test_results = @native MMap.put(test_results, test_pid, test_status);
//        [all_tests, test_results, all_tests_registered];
//      };
//        [{Tuple: [@_'start_test', test_name]}] => {
//        all_tests = @native MMap.put(all_tests, test_name, @_'running');
//        [all_tests, test_results, all_tests_registered];
//      };
//        [{Tuple: [@_'end_test', test_name]}] => {
//        all_tests = @native MMap.put(all_tests, test_name, @_'finished');
//        [all_tests, test_results, all_tests_registered];
//      };
//        [{Tuple: [@_'suite_finished']}] => {
//        [all_tests, test_results, @_'true'];
//      };
//        [{Tuple: [@_'get_result', respond_pid, test_pid]}] => {
//        test_result = @native MMap.get(test_results, test_pid);
//        Kernel.send(cast(respond_pid, Pid), cast(test_result, Tuple));
//        [all_tests, test_results, all_tests_registered];
//      };
//        [{Tuple: [@_'get', receive_pid]}] => {
//        Kernel.send(cast(receive_pid, Pid), cast([all_tests, test_results, all_tests_registered], Tuple));
//        [all_tests, test_results, all_tests_registered];
//      };
//        [{Tuple: [@_'reset']}] => {
//        DEFAULT_RESULTS;
//      };
//        [{Tuple: fallthrough}] => {
//        @native IO.inspect(fallthrough);
//        [all_tests, test_results, all_tests_registered];
//      };
//    });
//    test_results_store_loop(cast(received, Tuple));
//  });
//
//  @def add_test_result({Pid: test_pid, String: test_name, Atom: module, Atom: func, Atom: result, MMap: payload}, [Atom], {
//    pid = Kernel.get_pid_by_name(TEST_RESULTS);
//    Kernel.send(pid, [@_'save', test_pid, test_name, module, func, result, payload]);
//    @_'ok';
//  });
//
//  @def get_test_results([Tuple], {
//    pid = Kernel.get_pid_by_name(TEST_RESULTS);
//    self = Kernel.self();
//    Kernel.send(pid, [@_'get', self]);
//    Kernel.receive(@fn {
//        [{Tuple: result}] => {
//        result;
//      };
//    });
//  });
//
//  @def start_test({String: test_name}, [Atom], {
//    pid = Kernel.get_pid_by_name(TEST_RESULTS);
//    Kernel.send(pid, [@_'start_test', test_name]);
//    @_'ok';
//  });
//
//  @def end_test({String: test_name}, [Atom], {
//    pid = Kernel.get_pid_by_name(TEST_RESULTS);
//    Kernel.send(pid, [@_'end_test', test_name]);
//    @_'ok';
//  });
//
//  @def suite_finished([Atom], {
//    pid = Kernel.get_pid_by_name(TEST_RESULTS);
//    Kernel.send(pid, [@_'suite_finished']);
//    @_'ok';
//  });
//
//  @def update_status({Pid: test_pid, Atom: @_'pass'}, [Atom], {
//    status = @_'pass';
//    pid = Kernel.get_pid_by_name(TEST_RESULTS);
//    Kernel.send(pid, [@_'update_status', test_pid, status]);
//    Kernel.send(test_pid, status);
//    @_'ok';
//  });
//
//  @def update_status({Pid: test_pid, Atom: @_'fail'}, [Atom], {
//    status = @_'fail';
//    pid = Kernel.get_pid_by_name(TEST_RESULTS);
//    Kernel.send(pid, [@_'update_status', test_pid, status]);
//    self = Kernel.self();
//    Kernel.send(pid, [@_'get_result', self, test_pid]);
//    [test_name, module, func, new_status, payload] = Kernel.receive(@fn {
//        [{Tuple: results}, [Tuple]] => {
//        results;
//      };
//    });
//    test_name = cast(test_name, String);
//    end_test(test_name);
//    header = Str.concat("Test Failure: ", test_name);
//    System.println('');
//    System.println(header);
//    Kernel.exit(test_pid);
//    @_'ok';
//  });
//
//  @def reset([Atom], {
//    pid = Kernel.get_pid_by_name(TEST_RESULTS);
//    Kernel.send(pid, [@_'reset']);
//    @_'ok';
//  });
//
//  @def run_tests([Atom], {
//    reset();
//    all_tests_pid = Kernel.get_pid_by_name(ALL_TESTS);
//    self = Kernel.self();
//    Kernel.send(all_tests_pid, [@_'get', self]);
//    all_tests = Kernel.receive(@fn {
//        [{LList: all_tests}] => {
//        all_tests;
//      };
//    });
//    do_run_tests(cast(all_tests, LList));
//    wait_for_tests_to_complete();
//    @_'ok';
//  });
//
//  @def do_run_tests({LList: {}}, [Atom], {
//    @_'ok';
//  });
//
//  @def do_run_tests({LList: {module | rest;}}, [Atom], {
//    functions = @native Classes.getApiFunctions(module);
//    Kernel.spawn(@_'UnitTests', @_'run_test_case', [@_'Atom', @_'LList'], {module; functions;});
//    do_run_tests(cast(rest, LList));
//  });
//
//  @def wait_for_tests_to_complete([Atom], {
//    do_wait(@_'wait');
//  });
//
//  @def do_wait({Atom: @_'true'}, [Atom], {
//    System.println('');
//    @_'ok';
//  });
//
//  @def do_wait({Atom: _}, [Atom], {
//    [all_tests, _, all_tests_ran] = get_test_results();
//    result = did_all_tests_run(cast(all_tests, MMap), cast(all_tests_ran, Atom));
//    do_wait(result);
//  });
//
//  @def did_all_tests_run({MMap: all_tests, Atom: @_'true'}, [Atom], {
//    all_finished = EEnum.all(cast(all_tests, MMap), @fn {
//        [{Atom: @_'finished'}] => {
//        @_'true';
//      };
//        [{Atom: _}] => {
//        @_'false';
//      };
//    });
//    do_sleep = @fn {
//        [{Atom: @_'false'}] => {
//        Kernel.sleep(10);
//        @_'false';
//      };
//        [{Atom: _}] => {
//        @_'true';
//      };
//    }
//    do_sleep(all_finished);
//  });
//
//  @def did_all_tests_run({MMap: _, Atom: _}, [Atom], {
//    Kernel.sleep(10);
//    @_'false';
//  });
//
//  @def run_test_case({Atom: module, LList: {}}, [Tuple], {
//    suite_finished();
//    [@_'ok', 'tests complete'];
//  });
//
//  @def run_test_case({Atom: module, LList: {first | rest;}}, [Tuple], {
//    fun_string = @native Atom.to_s(first);
//    run_test(module, fun_string);
//    run_test_case(module, cast(rest, LList));
//  });
//
//  @def run_test({Atom: module, String: 'test_' => test_name}, [Atom], {
//    test_name = Str.concat('test_', test_name);
//    test_fun = @native Atom.create(test_name);
//    start_test(test_name);
//    pid = Kernel.spawn(@fn {
//        [{}] => {
//        module = cast(module, Atom);
//        test_fun = cast(test_fun, Atom);
//        self_pid = Kernel.self();
//
//        add_test_result(self_pid, test_name, module, test_fun, @_'no_assertions', []);
//        run_test(module, test_fun);
//        end_test(test_name);
//      };
//    });
//    Kernel.monitor(pid);
//    Kernel.receive(@fn {
//        [{Tuple: [@_"DOWN", pid, @_'crashed']}] => {
//        update_status(pid, @_'fail');
//      };
//        [{Tuple: status}] => {
//        System.print(".");
//      };
//    }, 60000);
//    @_'ok';
//  });
//
//  @def run_test({Atom: module, String: 'skip_' => test_name}, [Atom], {
//    System.print('*');
//    @_'no_test';
//  });
//
//  @def run_test({Atom: module, Atom: test_fun}, [Dynamic], {
//    Kernel.apply(module, test_fun, @tuple[], {});
//  });
//
//  @def run_test({Atom: module, String: _}, [Atom], {
//    @_'no_test';
//  });
//
//}))
//@:build(lang.macros.AnnaLang.deftype(SourceFile, {
//  var module_name: String = '';
//  var source_code: String = '';
//  var module_type: String = '';
//}))
//@:build(lang.macros.AnnaLang.deftype(ProjectConfig, {
//  var app_name: String = '';
//  var src_files: LList = {};
//}))
////@:build(lang.macros.AnnaLang.defmodule(AnnaCompiler, {
////  @alias util.Template;
////
////  @const PROJECT_SRC_PATH = 'project/';
////  @const ANNA_LANG_SUFFIX = '.anna';
////  @const HAXE_SUFFIX = '.hx';
////  @const BUILD_DIR = '_build/';
////  @const LIB_DIR = 'lib/';
////  @const OUTPUT_DIR = '_build/apps/main/';
////  @const RESOURCE_DIR = '../apps/compiler/resource/';
////  @const CONFIG_FILE = 'app_config.json';
////  @const BUILD_FILE = 'build.hxml';
////  @const CLASS_TEMPLATE_FILE = 'ClassTemplate.tpl';
////  @const BUILD_TEMPLATE_FILE = 'build.hxml.tpl';
////  @const HAXE_BUILD_MACR0_START = '@:build(lang.macros.AnnaLang.';
////  @const HAXE_BUILD_MACR0_END = ')';
////
////  @def build_project([Tuple], {
////    clean();
////    handle_config(get_config());
////  });
////
////  @def clean([Atom], {
////    result = File.rm_rf(BUILD_DIR);
////    result = File.mkdir_p(OUTPUT_DIR);
////    @_'ok';
////  });
////
////  @def get_config([Tuple], {
////    content = File.get_content(CONFIG_FILE);
////    JSON.parse(content);
////  });
////
////  @def handle_config({Tuple: [@_'ok', ["application" => app_name]]}, [Tuple], {
////    [@_'ok', files] = gather_source_files(LIB_DIR, {});
////    generate_template(cast(files, LList));
////    compile_app(cast(app_name, String));
////  });
////
////  @def handle_config({Tuple: error}, [Tuple], {
////    @native IO.inspect(error);
////    error;
////  });
////
////  @def gather_source_files({String: dir, LList: ret_val}, [Tuple], {
////    [@_'ok', files] = File.ls(dir);
////    result = EEnum.reduce(cast(files, LList), {}, @fn {
////      ([{String: file, LList: acc}, [LList]] => {
////        fun = @fn{
////          [{Atom: @_'true'}, [LList]] => {
////            filename = Str.concat(cast(dir, String), cast(file, String));
////            content = File.get_content(filename);
////
////            [@_'ok', module_name, module_type] = @native util.AST.getModuleInfo(content);
////
////            content = Str.concat(HAXE_BUILD_MACR0_START, content);
////            content = Str.concat(content, HAXE_BUILD_MACR0_END);
////
////            src_file = SourceFile%{source_code: content, module_name: module_name, module_type: module_type};
////
////            @native LList.add(acc, src_file);
////          };
////          [{Atom: @_'false'}, [LList]] => {
////            acc;
////          };
////        }
////        fun(Str.ends_with(file, ANNA_LANG_SUFFIX));
////      });
////    });
////    [@_'ok', result];
////  });
////
////  @def generate_template({LList: source_files}, [Tuple], {
////    template_file = Str.concat(RESOURCE_DIR, CLASS_TEMPLATE_FILE);
////    template = File.get_content(template_file);
////    [@_'ok', result] = @native Template.execute(template, ['source_files' => source_files]);
////
////    filename = 'Code';
////    filename = Str.concat(OUTPUT_DIR, filename);
////    filename = Str.concat(filename, HAXE_SUFFIX);
////
////    File.save_content(filename, cast(result, String));
////
////    [@_'ok', result];
////  });
////
////  @def compile_app({String: app_name}, [Tuple], {
////    //copy the app_config
////    app_config_destination = Str.concat(OUTPUT_DIR, CONFIG_FILE);
////    File.cp(CONFIG_FILE, app_config_destination);
////
////    //update the haxe build file
////    template_file = Str.concat(RESOURCE_DIR, BUILD_TEMPLATE_FILE);
////    template = File.get_content(template_file);
////
////    [@_'ok', result] = @native Template.execute(template, ["app_name" => app_name]);
////    template_file = Str.concat(BUILD_DIR, BUILD_FILE);
////    File.save_content(template_file, cast(result, String));
////
////    status = @native util.Compiler.compileProject();
////    @native IO.inspect(status);
////
////    [@_'ok', filename, result];
////  });
////}))
//@:build(lang.macros.AnnaLang.defmodule(File, {
//  @def get_content({String: file_path}, [String], {
//    #if cpp
//    @native sys.io.File.getContent(file_path);
//    #else
//    '';
//    #end
//  });
//
//  @def save_content({String: file_path, String: content}, [Tuple], {
//    #if cpp
//    @native sys.io.File.saveContent(file_path, content);
//    [@_'ok', file_path];
//    #else
//    [@_'error', 'not supported'];
//    #end
//  });
//
//  @def mkdir_p({String: dir}, [Tuple], {
//    #if cpp
//    @native sys.FileSystem.createDirectory(dir);
//    [@_'ok', dir];
//    #else
//    [@_'error', 'not supported'];
//    #end
//  });
//
//  @def rm_rf({String: dir}, [Tuple], {
//    #if cpp
//    @native util.File.removeAll(dir);
//    #else
//    [@_'error', 'not supported'];
//    #end
//  });
//
//  @def cp({String: src, String: dest}, [Tuple], {
//    #if cpp
//    @native sys.io.File.copy(src, dest);
//    [@_'ok', file_path];
//    #else
//    [@_'error', 'not supported'];
//    #end
//  });
//
//  @def ls({String: dir}, [Tuple], {
//    #if cpp
//    files = @native util.File.readDirectory(dir);
//    [@_'ok', files];
//    #else
//    [@_'error', 'not supported'];
//    #end
//  });
//
//  @def is_dir({String: dir}, [Tuple], {
//    #if cpp
//    result = @native util.File.isDirectory(dir);
//    [@_'ok', result];
//    #else
//    [@_'error', 'not supported'];
//    #end
//  });
//}))
////@:build(lang.macros.AnnaLang.defmodule(JSON, {
////  @def parse({String: data}, [Tuple], {
////    @native util.JSON.parse(data);
////  });
////
////  @def stringify({Tuple: [@_'ok', data]}, [Tuple], {
////    @native util.JSON.stringify(data);
////  });
////}))






















































@:build(lang.macros.AnnaLang.defmodule(AppCode, {
  @alias vm.Classes;
  @alias vm.Lang;
  @alias util.StringUtil;

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
    #if cpp
    content = @native sys.io.File.getContent(file_path);
    #else
    content = '';
    #end
    @native Lang.eval(content);
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
    AppCode.compile(main);
    @native Lang.eval('BootMain.start()');
    @_'ok';
  });
}))








@:build(lang.macros.AnnaLang.do_compile())
class Code {

}
