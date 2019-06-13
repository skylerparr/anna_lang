package vm;

class AnnaCallStack {
  private static var _id: Int = 0;

  public var operations: Array<Operation>;
  public var index: Int;
  public var id: Int;

  public var scopeVariables: Map<String, Dynamic>;

  public inline function new(code: Array<Operation>, scopeVariables: Map<String, Dynamic>) {
    this.operations = code;
    this.scopeVariables = scopeVariables;
    id = _id++;
  }

  public inline function execute(processStack: ProcessStack): Void {
    var operation: Operation = operations[index++];
    if(operation == null) {
      return;
    }
    operation.execute(scopeVariables, processStack);
  }

  public inline function finalCall(): Bool {
    return index >= operations.length;
  }

  public function toString(): String {
    return '${id}';
  }
}
