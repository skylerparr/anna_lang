package vm;

class Code {
  public var func: Dynamic;
  public var args: Array<Dynamic>;

  public inline function new(func: Dynamic, args: Array<Dynamic>) {
    this.func = func;
    this.args = args;
  }
}