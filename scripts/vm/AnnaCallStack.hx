package vm;

class AnnaCallStack {
  private static var _id: Int = 0;

  public var operations: Array<Operation>;
  public var index: Int;
  public var id: Int;

  public var scopeVariables: Map<String, Dynamic>;

  private var currentOperation: Operation;

  public inline function new(code: Array<Operation>, scopeVariables: Map<String, Dynamic>) {
    this.operations = code;
    this.scopeVariables = scopeVariables;
    currentOperation = operations[0];
    id = _id++;
  }

  public inline function execute(processStack: ProcessStack): Void {
    currentOperation = operations[index++];
//    Logger.inspect(operations.length, 'anna stack length ${this.toString()}');
//    Logger.inspect(index);
    if(currentOperation == null) {
      return;
    }
    currentOperation.execute(scopeVariables, processStack);
  }

  public inline function finalCall(): Bool {
    Logger.inspect(index >= operations.length - 1, '${index} >= ${operations.length} - 1');
    return index >= operations.length - 1;
  }

  public function toString(): String {
    return '${currentOperation}';
  }
}
