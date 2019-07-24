package lib;

import vm.Process;
import vm.Match;
import vm.Operation;
import vm.PushStack;
import vm.InvokeFunction;
import IO;
using lang.AtomSupport;

@:build(lang.macros.AnnaLang.defcls(Boot, {
  @alias vm.Process;

  @def start({
    pid = @native Process.self();
    @native IO.inspect(pid);
    p3 = print();
    p2 = print("hello world", 90210, 999);
    @native IO.inspect(p2);
    @native IO.inspect([@_"ok", "all correct"]);
    @native IO.inspect({@_"ok"; "all correct";});
    string = @native IO.inspect([ @_"ok" => "all", @_'error' => "correct"]);
    @native IO.inspect(p3);
//    @native IO.inspect({ok: "foob"}); //keyword list
//    print(pid);
  });

  @def print({
    @native IO.inspect('print with no args');
    pid = @native Process.self();
    "100";
    199.909;
    100;
    @_"money";
    [@_"tuple"];
    {@_"list"; @_"Smelly"; @_"Ellie";};
  });

  @def print({String: value, Int: count, Int: test}, [Int], {
    @native IO.inspect('print with 2 args');
    @native IO.inspect(value);
    @native IO.inspect(count);
    @native IO.inspect(test);
  });
}))
class Modules {
}