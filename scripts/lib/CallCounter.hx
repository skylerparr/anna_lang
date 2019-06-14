package lib;

import vm.Operation;
import vm.PushStack;
import vm.InvokeFunction;
import vm.IO;
using lang.AtomSupport;

//@:build(Macros.build())
class CallCounter {
  private static var _invoke: Array<Operation> = {
    _invoke = [];

    _invoke.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), "call counter invoking counter"])]));
//    _invoke.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), "ready?"])]));
//    _invoke.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
//    _invoke.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), "go..."])]));
    _invoke.push(new PushStack("Counter".atom(), 'increment_Int__Void'.atom(), [Macros.tuple(['const'.atom(), 60])]));
    _invoke.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), "done!"])]));
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