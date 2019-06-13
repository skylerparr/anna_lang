package vm;

class ProcessStack {
  private static var _id: Int = 0;

  public var allStacks: List<AnnaCallStack> = new List<AnnaCallStack>();
  private var currentStack: AnnaCallStack;
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
      allStacks.pop();
    }
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
    if(stackToExecute.finalCall() && !dontPop) {
      currentStack = allStacks.pop();
    } else {
      dontPop = false;
    }
  }

  public function toString(): String {
    return '${id}';
  }
}

