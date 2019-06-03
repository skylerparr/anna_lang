package vm;

using lang.AtomSupport;

class CallCounter {
  public static var invoke: Array<Operation> = {
    invoke = [];

    invoke.push(new InvokeFunction(Sys.println, ["call counter invoking counter"]));
    invoke.push(new PushStack("Counter".atom(), "increment".atom(), []));
    invoke.push(new InvokeFunction(Sys.println, ["Successfully called counter!"]));
    invoke.push(new InvokeFunction(Sys.println, ["recursion"]));
    invoke.push(new PushStack("CallCounter".atom(), "invoke".atom(), []));
    invoke;
  }


}