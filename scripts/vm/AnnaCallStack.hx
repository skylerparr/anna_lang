package vm;

class AnnaCallStack {
  public var operations: Array<Operation>;
  public var index: Int;

  public var scopeVariables: Map<String, Dynamic>;

  public inline function new(code: Array<Operation>, scopeVariables: Map<String, Dynamic>) {
    this.operations = code;
    this.scopeVariables = scopeVariables;
  }

  public inline function execute(processStack: ProcessStack): Void {
    var operation: Operation = operations[index++];
    operation.execute(scopeVariables, processStack);
  }

  public inline function finalCall(): Bool {
    return index == operations.length;
  }
}
