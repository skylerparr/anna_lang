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
    Logger.inspect(callStack.toString(), 'pushing stack');
    allStacks.push(callStack);
    currentStack = callStack;
  }

  public inline function execute(): Void {
    Logger.inspect("execute");
    var stackToExecute: AnnaCallStack = currentStack;
    if(stackToExecute == null) {
      Process.complete(Process.self());
      return;
    }
    Logger.inspect(stackToExecute.toString(), "currentStack");
    stackToExecute.execute(this);
    executionCount++;
    if(dontPop) {
      Logger.inspect("don't pop");
      dontPop = false;
      return;
    }
    if(stackToExecute.finalCall()) {
      Logger.inspect(currentStack.toString(), "----> popping stack");
      currentStack = allStacks.pop();
      if(currentStack != null) {
        Logger.inspect(currentStack.toString(), "currentStack");
      }
      Logger.inspect(currentStack.toString(), "----> popping stack");
      currentStack = allStacks.pop();
      if(currentStack != null) {
        Logger.inspect(currentStack.toString(), "currentStack");
      }
//    } else {
//      doPop = false;
      
    }
  }

  public function toString(): String {
    return '${id}';
  }
}

