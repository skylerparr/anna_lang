package lib;

import vm.Process;
import vm.Pid;
import vm.Match;
import vm.Operation;
import vm.PushStack;
import IO;
using lang.AtomSupport;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defcls(FunctionPatternMatching, {
  @alias vm.Kernel;

  @def start([Atom], {
    @native IO.inspect("testing function head pattern matching");
    @native IO.inspect("should count down to 0");
    result = count_down(10);
    match_tuple([@_"ok", "message"]);
    match_tuple([@_"error", "An error tuple has been handled"]);
    iterate_list({6; 5; 4; 3; 2; 1;});
    match_list({4; "hello";});
    match_map([@_"hello" => "world", @_"foo" => "bar"]);
    @_"ok";
  });

  @def count_down({Int: 0}, [Int], {
    @native IO.inspect(0);
    0;
  });

  @def count_down({Int: count}, [Int], {
    @native IO.inspect(count);
    count = @native Kernel.subtract(count, 1);
    count_down(count);
  });

  @def match_tuple({Tuple: [@_"ok", message]}, [Atom], {
    @native IO.inspect("handling ok");
    @native IO.inspect(message);
    @_"ok";
  });

  @def match_tuple({Tuple: [@_"error", message]}, [Atom], {
    @native IO.inspect("handling error");
    @native IO.inspect(message);
    @_"ok";
  });

  @def iterate_list({LList: {}}, [Atom], {
    @native IO.inspect("empty list");
    @_"ok";
  });

  @def iterate_list({LList: {hd | tl;}}, [Atom], {
    @native IO.inspect(hd);
    iterate_list(tl);
  });

  @def match_list({LList: {4; message;}}, [Atom], {
    @native IO.inspect(message);
    @_"ok";
  });

  @def match_map({MMap: [@_"hello" => value1, @_"foo" => value2]}, [Atom], {
    @native IO.inspect(value1);
    @native IO.inspect(value2);
    @_"ok";
  });
}))
@:build(lang.macros.AnnaLang.defcls(Boot, {
  @alias vm.Process;
  @alias vm.Pid;
  @alias vm.Kernel;

  @def start([Int], {
    print(get_string(), return_num(get_one()), get_two());
    result = @native Kernel.add(get_one(), get_two());
    @native IO.inspect(result);
    result = @native Kernel.add(result, get_one());
    @native IO.inspect(result);
    one_hundred = "100";
    pid = @native Process.self();
    counter = @native Kernel.add(23, 491);
    @native IO.inspect(counter);
    @native IO.inspect(null);
    @native IO.inspect(pid);
    p3 = print();
    p2 = print("hello world", 90210, counter);
    @native IO.inspect(p2);
    @native IO.inspect([@_"ok", "all correct"]);
    @native IO.inspect({@_"ok"; "all correct";});
    map = cast(@native IO.inspect([ @_"ok" => "all", @_'error' => "correct"]), MMap);
    @native IO.inspect(p3);
    @native IO.inspect(map);
//    @native IO.inspect("waiting...");
    fun = @fn {
      ([{Int: 10}, [Atom]] => {
        @native IO.inspect("got ten");
        @native IO.inspect(map);
        @_"ok";
      });
      ([{Int: 0}, [Atom]] => {
        @native IO.inspect("got zero");
        @native IO.inspect(map);
        @_"ok";
      });
      ([{Int: num}, [Atom]] => {
        @native IO.inspect(num);
        @_"ok";
      });
    }
    result = fun(map);
//    @native IO.inspect(result);
//    @native IO.inspect("waiting for data");
//    received = @native Kernel.receive(fun);
//    @native IO.inspect("received:");
//    @native IO.inspect(received);

//    print(result);
//    received = @native Kernel.receive(@fn{
//      ([{String: foo}, [Dynamic]] => {
//        value;
//      });
//    });
//    @native IO.inspect("received:");
//    @native IO.inspect(received);
    foo(p3);
    foo(p2);
    bar(map);
//    @native IO.inspect({ok: "foob"}); //keyword list
    print(pid);
  });

  @def print([Int], {
    @native IO.inspect('print with no args');
    arg1 = "100";
    pid = @native Process.self();
    199.909;
    arg2 = 100;
    @_"money";
    [@_"tuple"];
    list = {@_"list"; @_"Smelly"; @_"Ellie";};
    arg3 = 300;
    arg4 = arg3;
    @native IO.inspect(arg3);
    @native IO.inspect(arg4);
    @native IO.inspect(list);
    @native IO.inspect({});
    @native IO.inspect("returning");
    arg4;
  });

  @def print({String: value, Int: count, Int: test}, [Int], {
    @native IO.inspect('print with 2 args');
    @native IO.inspect(value);
    @native IO.inspect(count);
    @native IO.inspect(test);
  });

  @def print({String: string}, [String], {
    @native IO.inspect(string);
    string;
  });

  @def print({Atom: val}, [Atom], {
    @native IO.inspect(val);
    val;
  });

  @def print({Pid: process}, [Atom], {
    @native IO.inspect(process);
    @_'ok';
  });

  @def foo({Int: value}, [String], {
    @native IO.inspect("In foo");
    @native IO.inspect(value);
  });

  @def bar({MMap: map}, [String], {
    @native IO.inspect("in bar");
    @native IO.inspect(map);
  });

  @def get_string([String], {
    "hello world";
  });

  @def get_one([Int], {
    1;
  });

  @def get_two([Int], {
    2;
  });

  @def return_num({Int: number}, [Int], {
    number;
  });

  @def get_atom([Atom], {
    @_'ok';
  });
}))
@:build(lang.macros.AnnaLang.compile())
class Modules {
}