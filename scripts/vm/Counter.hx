package vm;

using lang.AtomSupport;

class Counter {

  private static var _increment: Array<Operation> = {
    _increment = [];

    _increment.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), 'start'])]));
    _increment.push(new InvokeFunction(IO.inspect, [Macros.tuple(['var'.atom(), 'count'])]));
    _increment.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _increment.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), 1])]));
    _increment.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _increment.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), 2])]));
    _increment.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _increment.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), 3])]));
    _increment.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _increment.push(new InvokeFunction(IO.inspect, [Macros.tuple(['const'.atom(), 'end'])]));
    _increment;
  }

  public static function increment(count: Int): Array<Operation> {
    return _increment;
  }

  public static function ___increment_args(): Array<String> {
    var args: Array<String> = [];
    args.push('count');
    return args;
  }
}