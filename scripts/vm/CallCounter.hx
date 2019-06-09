package vm;

using lang.AtomSupport;

class CallCounter {
  private static var _invoke: Array<Operation> = {
    _invoke = [];

    _invoke.push(new InvokeFunction(Sys.println, [Tuple.create(['const'.atom(), "call counter invoking counter"])]));
    _invoke.push(new PushStack("Counter".atom(), 'increment'.atom(), [Tuple.create(['const'.atom(), 8])]));
    _invoke.push(new InvokeFunction(Sys.println, [Tuple.create(['const'.atom(), "Successfully called counter!"])]));
    _invoke.push(new InvokeFunction(Sys.println, [Tuple.create(['const'.atom(), "recursion"])]));
    _invoke.push(new PushStack("CallCounter".atom(), 'invoke'.atom(), []));
    _invoke;
  }

  public static function invoke(): Array<Operation> {
    return _invoke;
  }

}