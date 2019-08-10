package vm;

class ProcessStack {
  private static var _id: Int = 0;

  public var allStacks: List<AnnaCallStack> = new List<AnnaCallStack>();
  public var currentStack: AnnaCallStack;
  private var process: Process;
  private var executionCount: Int;
  public var id: Int;

  public function new(process: Process) {
    this.process = process;
    this.id = _id++;
  }

  public inline function add(callStack: AnnaCallStack): Void {
    if(currentStack != null && currentStack.tailCall) {
      allStacks.pop();
    }
    allStacks.push(callStack);
    currentStack = callStack;
  }

  public inline function execute(): Void {
    if(allStacks.length == 0) {
      Process.complete(process);
      return;
    }
    currentStack = allStacks.first();
    currentStack.execute(this);
    executionCount++;
    if(currentStack.finalCall()) {
      var annaStack = allStacks.pop();
      var retVal = annaStack.scopeVariables.get("$$$");
      var nextStack = allStacks.first();
      if(nextStack != null) {
        nextStack.scopeVariables.set("$$$", retVal);
      }
    }
  }

  public function toString(): String {
    return 'ProcessStack: ${id}';
  }

  public function printStackTrace(): Void {
    for(cs in allStacks) {
      Logger.inspect(cs.toString());
    }
  }
}

