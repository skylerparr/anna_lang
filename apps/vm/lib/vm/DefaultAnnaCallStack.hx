package vm;

class DefaultAnnaCallStack implements AnnaCallStack {
  private static var _id: Int = 0;

  public var operations: Array<Operation>;
  public var index: Int;
  public var id: Int;

  public var scopeVariables: Map<String, Dynamic>;

  public var currentOperation: Operation;

  public inline function new(code: Array<Operation>, scopeVariables: Map<String, Dynamic>) {
    this.operations = code;
    this.scopeVariables = scopeVariables;
    currentOperation = operations[0];
    id = _id++;
  }

  public function init(): Void {
  }

  public function dispose(): Void {
    operations = null;
    scopeVariables = null;
    currentOperation = null;
  }

  public inline function execute(processStack: ProcessStack): Void {
    Logger.log(processStack, 'process stack');
    Logger.log(currentOperation, 'current operation');
    currentOperation = operations[index++];
    Logger.log(currentOperation);
    if(currentOperation == null) {
      return;
    }
    var scope = new Map<String, Dynamic>();
    for(key in scopeVariables.keys()) {
      scope.set(key, scopeVariables.get(key));
    }
    scopeVariables = scope;
    Logger.log(scopeVariables);
    currentOperation.execute(scopeVariables, processStack);
  }

  public inline function finalCall(): Bool {
    return index >= operations.length;
  }

  public function toString(): String {
    if(currentOperation == null) {
      return '';
    }
    return '${currentOperation.toString()}';
  }
}
