package vm;

class ProcessStack {

  private var allStacks: List<AnnaCallStack> = new List<AnnaCallStack>();
  private var currentStack: AnnaCallStack;
  private var process: Process;
  private var executionCount: Int;

  public function new(process: Process) {
    this.process = process;
  }

  public inline function add(callStack: AnnaCallStack): Void {
    allStacks.push(callStack);
    currentStack = callStack;
  }

  public inline function execute(): Void {
    if(currentStack.empty()) {
      allStacks.pop();
      currentStack = allStacks.first();
    }
    if(currentStack == null) {
      Process.complete(Process.self());
    } else {
      currentStack.execute();
      executionCount++;
    }
  }
}

