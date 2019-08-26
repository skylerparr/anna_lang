package lib;

import compiler.CppiaCompiler;
import vm.Process;
import vm.Match;
import vm.Operation;
import vm.PushStack;
import IO;
using lang.AtomSupport;
@:build(lang.macros.AnnaLang.init())
@:build(lang.macros.AnnaLang.defcls(AnnaLangCompiler, {
  @alias fs.File;
  @alias compiler.CppiaCompiler;

  @def start([Atom], {
    @native IO.inspect("starting compiler");
    @native CppiaCompiler.start();
    code = @native File.read("apps/anna/anna.anna");
    ast = @native CppiaCompiler.ast(code);
    @native IO.inspect(ast);
//    code_string = @native CppiaCompiler.astToString(ast);
//    @native IO.inspect(code_string);
//    Boot.start();
    @_"ok";
  });
}))
@:build(lang.macros.AnnaLang.defcls(FunctionPatternMatching, {
  @def start([Atom], {
    @_"ok";
  });
}))
@:build(lang.macros.AnnaLang.defcls(Boot, {
  @alias vm.Process;
  @alias vm.Kernel;

  @def start([Int], {
    print(get_string(), return_num(get_one()), get_two());
//    result = @native Kernel.add(get_one(), get_two());
//    @native IO.inspect(result);
//    result = @native Kernel.add(result, get_one());
//    @native IO.inspect(result);
//    one_hundred = "100";
//    pid = @native Process.self();
//    counter = @native Kernel.add(23, 491);
//    @native IO.inspect(counter);
//    @native IO.inspect(null);
//    @native IO.inspect(pid);
//    p3 = print();
//    p2 = print("hello world", 90210, counter);
//    @native IO.inspect(p2);
//    @native IO.inspect([@_"ok", "all correct"]);
//    @native IO.inspect({@_"ok"; "all correct";});
//    map = cast(@native IO.inspect([ @_"ok" => "all", @_'error' => "correct"]), MMap);
//    @native IO.inspect(p3);
//    @native IO.inspect(map);
//    @native IO.inspect("waiting...");
//    fun = @fn {
//      ([{String: foo}, [String]] => {
//        foo;
//      });
//      ([{Int: int}, [Atom]] => {
//        @native IO.inspect("got zero");
//        @_"ok";
//      });
//    }
//    result = fun("foo");
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
//    foo(p3);
//    foo(p2);
//    bar(map);
//    @native IO.inspect({ok: "foob"}); //keyword list
//    print(pid);
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