package lib;

import vm.Process;
import vm.Match;
import vm.Operation;
import vm.PushStack;
import vm.InvokeFunction;
import IO;
using lang.AtomSupport;

@:build(lang.macros.AnnaLang.defcls(Boot, {
  @def start({
    pid = @native vm.Process.self();
    @native IO.inspect(@tuple[@atom 'var', 'pid']);
    print();
    print("hello world", 90210);
  });

  @def print({
    @native IO.inspect(@tuple[@atom 'const', 'print with no args']);
  });

  @def print(@String value, @Int count, {
    @native IO.inspect(@tuple[@atom 'const', 'print with 2 args']);
    @native IO.inspect(@tuple[@atom 'var', 'value']);
    @native IO.inspect(@tuple[@atom 'var', 'count']);
  });
}))
class Modules {
}