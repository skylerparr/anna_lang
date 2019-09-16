package vm;
import cpp.vm.Thread;
import vm.Function;
using lang.AtomSupport;
class Process {
  public static function putInMailbox(process: Pid, value: Dynamic): Void {
    process.mailbox.push(value);
  }

  public static function printStackTrace(process: Pid): Void {
    process.processStack.printStackTrace();
  }

  public static function isAlive(process: Pid): Atom {
    return switch(process.state) {
      case ProcessState.COMPLETE | ProcessState.KILLED | ProcessState.CRASHED:
        'false'.atom();
      case _:
        'true'.atom();
    }
  }

  public static function status(pid: Pid): String {
    return pid.state + "";
  }

  public static function exit(process: Pid): Atom {
    Reflect.setField(process, 'state', ProcessState.KILLED);
    return 'ok'.atom();
  }

  public static function running(process: Pid): Atom {
    Reflect.setField(process, 'state', ProcessState.RUNNING);
    return 'ok'.atom();
  }

  public static function complete(process: Pid): Atom {
    Reflect.setField(process, 'state', ProcessState.COMPLETE);
    return 'ok'.atom();
  }

  public static function waiting(process: Pid): Atom {
    Reflect.setField(process, 'state', ProcessState.WAITING);
    return 'ok'.atom();
  }

  public static function receive(process: Pid, callback: Function): Atom {
    return 'ok'.atom();
  }

  public static function self(): Pid {
    var pid: Pid = Kernel.currentScheduler.self();
    return pid;
  }

  public static function sleep(milliseconds: Int): Atom {
    Kernel.currentScheduler.sleep(self(), milliseconds);
    return 'ok'.atom();
  }

  public static function apply(process: Pid, ops: Array<Operation>): Void {
    var processStack = process.processStack;
    processStack.add(new DefaultAnnaCallStack(ops, processStack.getVariablesInScope()));
  }
}
