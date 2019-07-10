package lib;

import vm.Process;
import vm.Match;
import vm.Operation;
import vm.PushStack;
import vm.InvokeFunction;
import IO;
using lang.AtomSupport;

@:build(lang.macros.AnnaLang.defcls(Boot, {
  @alias lang.macros.MacroContext;

  @def start({
    @native IO.inspect(@tuple[@atom 'const', "defining anna :)"]);
    @native MacroContext.define_callback(@tuple[@atom 'const', @atom 'Lang'], @tuple[@atom 'const', @atom 'macro']);
//    @native tests.mock.fixture.Sample.foo();
//    @native Process.sleep(@list[@tuple[@atom 'const', 500]]);
//    @native IO.inspect(@list[@tuple[@atom 'const', "just for kicks"]]);
    print();
    @native IO.inspect(@tuple[@atom 'const', 'finished printing']);
  });

  @def print({
    hello();
    @native IO.inspect(@tuple[@atom 'const', 'you are printing']);
    hello();
  });

  @def hello({
    @native IO.inspect(@tuple[@atom 'const', 'hello world']);
  });
}))
class Modules {

//  public static var _invoke: Array<Operation> = {
//    _invoke = [];
//
////    Logger.inspect(@map[@tuple['_invoke'] => "val"]);
////
//    _invoke.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), "call counter invoking counter"]]));
//    _invoke.push(new InvokeFunction(Anna.subtract, [@tuple['const'.atom(), 10], @tuple['const'.atom(), 1]]));
//    _invoke.push(new Match(@tuple['var'.atom(), 'result'], @tuple['var'.atom(), "$$$"]));
//    _invoke.push(new InvokeFunction(IO.inspect, [@tuple['var'.atom(), 'result']]));
////    _invoke.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), "ready?"])]));
////    _invoke.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
//    _invoke.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), "go..."]]));
//    _invoke.push(new PushStack("Counter".atom(), 'increment_Int__Void'.atom(), [@tuple['const'.atom(), 5]]));
////    _invoke.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), "done!"]]));
////    _invoke.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), "recursion"])]));
////    _invoke.push(new PushStack("CallCounter".atom(), 'invoke'.atom(), []));
//    _invoke;
//  }
//
//  public static function invoke(): Array<Operation> {
//    return _invoke;
//  }
//
//  public static function ___invoke_args(): Array<String> {
//    var args: Array<String> = [];
//    return args;
//  }

}