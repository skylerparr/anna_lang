package vm;

import vm.Code;
class AnnaCallStack {
  public var code: Array<Code>;
  public var index: Int;

  public var scopeVariables: Map<String, Dynamic>;

  public inline function new(code: Array<Code>) {
    this.code = code;
    scopeVariables = new Map<String, Dynamic>();
  }

  public inline function execute(): Void {
    var exec: Code = code[index++];
    Reflect.callMethod(null, exec.func, exec.args);
  }

  public inline function empty(): Bool {
    return index == code.length;
  }
}
