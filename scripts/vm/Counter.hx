package vm;

using lang.AtomSupport;

@:build(Macros.build())
class Counter {

  private static var _increment: Array<Operation> = {
    _increment = [];

    _increment.push(new InvokeFunction(Sys.println, [Macros.tuple(['const'.atom(), 'start'])]));
    _increment.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _increment.push(new InvokeFunction(Sys.println, [Macros.tuple(['const'.atom(), 1])]));
    _increment.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _increment.push(new InvokeFunction(Sys.println, [Macros.tuple(['const'.atom(), 2])]));
    _increment.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _increment.push(new InvokeFunction(Sys.println, [Macros.tuple(['const'.atom(), 3])]));
    _increment.push(new InvokeFunction(Process.sleep, [Macros.tuple(['const'.atom(), 500])]));
    _increment.push(new InvokeFunction(Sys.println, [Macros.tuple(['const'.atom(), 'end'])]));
    _increment;
  }

  public static function increment(count: Int): Array<Operation> {
    return _increment;
  }

  public static function test(): Void {
    var tuple: Tuple = Macros.tuple(['const'.atom(), 'start']);
//    var t: Tuple = @tuple(['const'.atom(), 'start'])
    Logger.inspect(tuple);
  }
}