package vm;

class Counter {

  public static var increment: Array<Operation> = {
    increment = [];

    increment.push(new InvokeFunction(Sys.println, ["start"]));
    increment.push(new InvokeFunction(Process.sleep, [1000]));
    increment.push(new InvokeFunction(Sys.println, [1]));
    increment.push(new InvokeFunction(Process.sleep, [1000]));
    increment.push(new InvokeFunction(Sys.println, [2]));
    increment.push(new InvokeFunction(Process.sleep, [1000]));
    increment.push(new InvokeFunction(Sys.println, [3]));
    increment.push(new InvokeFunction(Process.sleep, [1000]));
    increment.push(new InvokeFunction(Sys.println, ["end"]));
    increment;
  }

}