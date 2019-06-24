package lib;

import vm.Match;
import vm.Operation;
import vm.PushStack;
import vm.InvokeFunction;
import vm.IO;
using lang.AtomSupport;

@:build(Macros.build())
class CallCounter {
  public static var _invoke: Array<Operation> = {
    _invoke = [];

//    Logger.inspect(@map[@tuple['_invoke'] => "val"]);
//
    _invoke.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), "call counter invoking counter"]]));
    _invoke.push(new InvokeFunction(Anna.subtract, [@tuple['const'.atom(), 10], @tuple['const'.atom(), 1]]));
    _invoke.push(new Match(@tuple['var'.atom(), 'result'], @tuple['var'.atom(), "$$$"]));
    _invoke.push(new InvokeFunction(IO.inspect, [@tuple['var'.atom(), 'result']]));
//    _invoke.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), "ready?"])]));
//    _invoke.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _invoke.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), "go..."]]));
    _invoke.push(new PushStack("Counter".atom(), 'increment_Int__Void'.atom(), [@tuple['const'.atom(), 5]]));
//    _invoke.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), "done!"]]));
//    _invoke.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), "recursion"])]));
//    _invoke.push(new PushStack("CallCounter".atom(), 'invoke'.atom(), []));
    _invoke;
  }

  public static function invoke(): Array<Operation> {
    return _invoke;
  }

  public static function ___invoke_args(): Array<String> {
    var args: Array<String> = [];
    return args;
  }

}