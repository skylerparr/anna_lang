package vm;

class ProcessStack {

  public var allStacks: List<AnnaCallStack> = new List<AnnaCallStack>();
  private var currentStack: AnnaCallStack;
  private var process: Process;
  private var executionCount: Int;

  public function new(process: Process) {
    this.process = process;
  }

  public inline function add(callStack: AnnaCallStack): Void {
    if(currentStack != null && currentStack.finalCall()) {
      allStacks.pop();
    }
    allStacks.push(callStack);
    currentStack = callStack;
  }

  public inline function execute(): Void {
    if(currentStack == null) {
      Process.complete(Process.self());
      return;
    }
    currentStack.execute(this);
    executionCount++;
    if(currentStack.finalCall()) {
      allStacks.pop();
      currentStack = allStacks.first();
    }
  }
}

