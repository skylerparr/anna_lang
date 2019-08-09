package lib;

import vm.Process;
import vm.Match;
import vm.Operation;
import vm.PushStack;
import IO;
using lang.AtomSupport;

@:build(lang.macros.AnnaLang.defcls(Boot, {
  @alias vm.Process;
  @alias vm.Kernel;

  @def start([Int], {
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
    foo(p3);
    foo(p2);
    bar(map);
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

  @def foo({Int: value}, [String], {
    @native IO.inspect("In foo");
    @native IO.inspect(value);
  });

  @def bar({MMap: map}, [String], {
    @native IO.inspect("in bar");
    @native IO.inspect(map);
  });
}))
class Modules {
}