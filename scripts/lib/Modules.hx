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
    print();
    print("hello world", 90210, 999);
    print(pid);
  });

  @def print({
    @native IO.inspect('print with no args');
  });

//  @def print({Tuple: {abc; def;}}, [{error: String} | {ok: Proc}], {
//    @native IO.inspect(pid);
//    {abc; def;} // tuple?
//    [a, b, c]; // tuple?
//    [a | b | c]; // list
//    Process%[a => b, c => d]; //custom type (struct)
//    [a => b, c => d]; // map
//    {abc: def}; // typespec
//    {abc | def;}; // usable syntax
//  });

  @def print({String: value, Int: count, Int: test}, [Int], {
    @native IO.inspect('print with 2 args');
    @native IO.inspect(value);
    @native IO.inspect(count);
    @native IO.inspect(test);

  });
}))
class Modules {
}