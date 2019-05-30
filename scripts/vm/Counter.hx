package vm;

class Counter {

  public static var increment: Array<Code>;

  public static function _increment(): Void {
    increment = [];

    increment.push(new Code(Sys.println, ["start"]));
    increment.push(new Code(Process.sleep, [1000]));
    increment.push(new Code(Sys.println, [1]));
    increment.push(new Code(Process.sleep, [1000]));
    increment.push(new Code(Sys.println, [2]));
    increment.push(new Code(Process.sleep, [1000]));
    increment.push(new Code(Sys.println, [3]));
    increment.push(new Code(Process.sleep, [1000]));
    increment.push(new Code(Sys.println, ["end"]));
  }
}