package vm;

class ProcessStack {
  private static var _id: Int = 0;

  public var allStacks: List<AnnaCallStack> = new List<AnnaCallStack>();
  public var currentStack: AnnaCallStack;
  private var process: Process;
  private var executionCount: Int;
  private var dontPop: Bool;
  public var id: Int;

  public function new(process: Process) {
    this.process = process;
    this.id = _id++;
  }

  public inline function add(callStack: AnnaCallStack): Void {
    if(currentStack != null && currentStack.finalCall()) {
      dontPop = true;
//      allStacks.pop();
    }
//    Logger.inspect(callStack.toString(), "push stack");
    allStacks.push(callStack);
    currentStack = callStack;
  }

  public inline function execute(): Void {
    var stackToExecute: AnnaCallStack = currentStack;
    if(stackToExecute == null) {
      Process.complete(Process.self());
      return;
    }
    stackToExecute.execute(this);
    executionCount++;
    if(dontPop) {
      Logger.inspect("don't pop");
      dontPop = false;
      return;
    }
    if(stackToExecute.finalCall()) {
      currentStack = allStacks.pop();
//    } else {
//      doPop = false;
      
    }
  }

  public function toString(): String {
    return '${id}';
  }
}

