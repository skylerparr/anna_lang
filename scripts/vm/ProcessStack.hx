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
      Debug.pry("adding call stack");
      dontPop = true;
      allStacks.pop();
    }
    Debug.pry("pushing call stack");
    allStacks.push(callStack);
    currentStack = callStack;
  }

  public inline function execute(): Void {
    var stackToExecute: AnnaCallStack = currentStack;
    if(stackToExecute == null) {
      Process.complete(Process.self());
      return;
    }
    Debug.pry("about to execute");
    stackToExecute.execute(this);
    Debug.pry("just finished executing");
    executionCount++;
    if(dontPop) {
      dontPop = false;
      return;
    }
    Debug.pry("should we pop?");
    if(stackToExecute.finalCall()) {
      currentStack = allStacks.pop();
      Debug.pry("we just popped");
//    } else {
//      doPop = false;
      
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

