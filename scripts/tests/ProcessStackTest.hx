package tests;

import vm.Operation;
import anna_unit.Assert;
import vm.Process;
import vm.AnnaCallStack;
import vm.ProcessStack;
@:build(Macros.build())
class ProcessStackTest {

  private static var stack: ProcessStack;

  public static function setup(): Void {
    stack = new ProcessStack(new Process(1, 2, 3, createAnnaCallStack()));
  }

  public static function shouldAddAnnaCallStackToTheProcessStack(): Void {
    stack.add(createAnnaCallStack());
    stack.add(createAnnaCallStack());
    stack.add(createAnnaCallStack());

    @assert stack.allStacks.length == 3;
  }

  public static function shouldExecuteStackAndPopAnnaStack(): Void {
    stack.add(createAnnaCallStack());
    stack.add(createAnnaCallStack());
    stack.add(createAnnaCallStack());

    stack.execute();
    @assert stack.allStacks.length == 2;

    stack.execute();
    @assert stack.allStacks.length == 1;

    stack.execute();
    @assert stack.allStacks.length == 0;
  }

  public static function shouldNotAddToStackIfCurrentStackIsFinalCall(): Void {
    stack.add(createAnnaCallStack(0));
    stack.add(createAnnaCallStack(0));
    stack.add(createAnnaCallStack(0));

    @assert stack.allStacks.length == 1;
  }

  private static function createAnnaCallStack(opCount: Int = 3): AnnaCallStack {
    var ops: Array<Operation> = [];
    for(i in 0...opCount) {
      ops.push(op());
    }
    return new AnnaCallStack(ops, createMap());
  }

  private static function createMap(): Map<String, Dynamic> {
    return new Map<String, Dynamic>();
  }

  private static function op(): Operation {
    return new MockOperation();
  }
}

class MockOperation implements Operation {

  public function new() {
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
  }

  public var hostModule: String;

  public var hostFunction: String;

  public var lineNumber: Int;

  public function toString(): String {
    return '';
  }
}