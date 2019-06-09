package vm;

using lang.AtomSupport;

class Counter {

  private static var _increment: Array<Operation> = {
    _increment = [];

//    _increment.push(new InvokeFunction(Sys.println, [Tuple.create(either(['const'.atom(), 'start']))]));
//    _increment.push(new InvokeFunction(Process.sleep, [Tuple.create('const'.atom(), 500)]));
//    _increment.push(new InvokeFunction(Sys.println, [Tuple.create('const'.atom(), 1)]));
//    _increment.push(new InvokeFunction(Process.sleep, [Tuple.create('const'.atom(), 500)]));
//    _increment.push(new InvokeFunction(Sys.println, [Tuple.create('const'.atom(), 2)]));
//    _increment.push(new InvokeFunction(Process.sleep, [Tuple.create('const'.atom(), 500)]));
//    _increment.push(new InvokeFunction(Sys.println, [Tuple.create('const'.atom(), 3)]));
//    _increment.push(new InvokeFunction(Process.sleep, [Tuple.create('const'.atom(), 500)]));
//    _increment.push(new InvokeFunction(Sys.println, [Tuple.create('const'.atom(), "end")]));
    _increment;
  }

  public static function increment(count: Tuple): Array<Operation> {
    return _increment;
  }

  public static function test(): Void {
    var tuple: Tuple = Tuple.create(Macros.ei(['const'.atom(), 'start', 1, 2.12]));
    Logger.inspect(tuple);
    trace(Macros.ei(['const'.atom(), 'start', 1, 2]));
  }
}