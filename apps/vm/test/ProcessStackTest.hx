package ;

import vm.ProcessStack;
import vm.AnnaCallStack;
import vm.DefaultAnnaCallStack;
import vm.Operation;
import anna_unit.Assert;
import vm.SimpleProcess;
import vm.DefaultProcessStack;
@:build(lang.macros.Macros.build())
class ProcessStackTest {

  private static var stack: DefaultProcessStack;

  public static function setup(): Void {
    stack = new DefaultProcessStack(new SimpleProcess(1, 2, 3, op()));
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
    @assert stack.allStacks.length == 3;

    stack.execute();
    @assert stack.allStacks.length == 3;

    stack.execute();
    @assert stack.allStacks.length == 2;

    stack.execute();
    @assert stack.allStacks.length == 2;

    stack.execute();
    @assert stack.allStacks.length == 2;

    stack.execute();
    @assert stack.allStacks.length == 1;

    stack.execute();
    @assert stack.allStacks.length == 1;

    stack.execute();
    @assert stack.allStacks.length == 1;

    stack.execute();
    @assert stack.allStacks.length == 0;
  }

  private static function createAnnaCallStack(opCount: Int = 3): AnnaCallStack {
    var ops: Array<Operation> = [];
    for(i in 0...opCount) {
      ops.push(op());
    }
    return new DefaultAnnaCallStack(ops, createMap());
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

  public function isRecursive(): Bool {
    return false;
  }

  public var hostModule: Atom;

  public var hostFunction: Atom;

  public var lineNumber: Int;

  public function toString(): String {
    return '';
  }
}