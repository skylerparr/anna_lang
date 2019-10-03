package ;

/**
* NOT SURE WHY, but this file MUST live in the lib directory in order to compile.
**/
import vm.Pid;
import IO;
using lang.AtomSupport;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defType(Sample, {
  var name: String = "Ellie";
  var age: Int;
  var payload: MMap = [@_"hello" => "world"];
  var type: Cat = Cat%{name: "Face", face: 'numb'};
  var legs: LList = {1; 2; 3;};
  var hair: Tuple = [@_"long", "green"];
}))
@:build(lang.macros.AnnaLang.defType(Cat, {
  var name: String = "Weird";
  var face: String = "dumb";
}))
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
    match_list({8; "fire";});
    match_map([@_"hello" => "world", @_"foo" => "bar", @_"foocat" => [@_"cat" => "baz"]]);
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

  @def test_receive([Atom], {
    fun = @fn {
      ([{String: value}, [String]] => {
        @native IO.inspect("handling received message");
        @native IO.inspect(value);
        value;
      });
    }
    @native IO.inspect("waiting for data");
    received = @native Kernel.receive(fun);
    @native IO.inspect("received:");
    @native IO.inspect(received);
    @_"ok";
  });

  @def start([Int], {
    print(get_string(), return_num(get_one()), get_two());
    result = @native Kernel.add(get_one(), get_two());
    @native IO.inspect(result);
    result = @native Kernel.add(result, get_one());
    @native IO.inspect(result);
    one_hundred = "100";
    @native IO.inspect("getting self");
    pid = @native Process.self();
    @native IO.inspect("sleeping");
    @native Process.sleep(1000);
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
    result = fun(5);
    @native IO.inspect(result);
    fun2 = @fn {
      ([{String: "cow"}, [String]] => {
        @native IO.inspect("have a cow");
      });
      ([{String: val}, [String]] => {
        @native IO.inspect("no cows");
        @native IO.inspect(val);
      });
    }
    result = fun(0);
    @native IO.inspect(result);
    result2 = fun2("cow");
    @native IO.inspect(result2);
    result = fun(10);
    @native IO.inspect(result);
    result2 = fun2("monkey");
    @native IO.inspect(result2);

    result3 = fun3("foo");

    @native IO.inspect(result3);
    @native IO.inspect("testing assignment matching");
    [@_"ok", msg] = sample();
    @native IO.inspect("expecting 'message'");
    @native IO.inspect(msg);

    cake = sample();
    [@_"ok", message] = cake;
    @native IO.inspect("expecting 'message'");
    @native IO.inspect(msg);

    sample_type = Sample%{name: "foo", age: 20, payload: [@_"ok" => "ack"]};
    print_sample(sample_type);
    @native IO.inspect([@_"hello" => "world", @_"foo" => "bar", @_"foocat" => [@_"cat" => "baz"]]);
    foo(p3);
    foo(p2);
    bar(map);
    @native IO.inspect(get_tuple());
    @native IO.inspect(get_list());
    @native IO.inspect(get_map());
    @native IO.inspect(get_all());

    [@_"ok", {@_"mouse"; [@_"stinky" => "bear", @_"bean" => "dipper", [@_"foo", "bar"] => "feet",
      @list["apple", "orange"] => "fruit", [@_"always" => "squirreling"] => for_what];}] = get_all();
    @native IO.inspect("What is Ellie always squirreling for?");
    @native IO.inspect(for_what);
//    @native IO.inspect({ok: "foob"}); //keyword list
    print(pid);
  });

  @def print_sample({Sample: s}, [Sample], {
    @native IO.inspect('printing sample type');
    @native IO.inspect(s);
    s;
  });

  @def get_tuple([Tuple], {
    [@_"ok", [@_'tuple', 'free']];
  });

  @def get_list([List], {
    {1; 2; {@_"a"; @_"b"; @_"c";}};
  });

  @def get_map([MMap], {
    [[@_"always" => "squirreling"] => "for nuts"];
  });

  @def get_all([Tuple], {
    [@_"ok", {@_"mouse"; [@_"stinky" => "bear", @_"bean" => "dipper", [@_"foo", "bar"] => "feet",
      @list["apple", "orange"] => "fruit", [@_"always" => "squirreling"] => "for nuts"];}];
  });

  @def sample([Tuple], {
    [@_"ok", "message"];
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
class AcceptanceTests {
}