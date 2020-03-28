package vm;
import vm.Pid;
using lang.AtomSupport;
@:rtti
class Process {
  public static function putInMailbox(process: Pid, value: Dynamic): Void {
    process.mailbox.push(value);
  }

  public static function printStackTrace(process: Pid): Atom {
    process.processStack.printStackTrace();
    return 'ok'.atom();
  }

  public static function isAlive(process: Pid): Atom {
    return switch(process.state) {
      case ProcessState.COMPLETE | ProcessState.KILLED | ProcessState.CRASHED:
        'false'.atom();
      case _:
        'true'.atom();
    }
  }

  public static function status(pid: Pid): Atom {
    return (pid.state + "").atom();
  }

  public static function complete(pid: Pid): Atom {
    NativeKernel.currentScheduler.complete(pid);
    return 'ok'.atom();
  }

  public static function self(): Pid {
    return NativeKernel.currentScheduler.self();
  }

  public static function getDictionary(): MMap {
    return self().dictionary;
  }

  public static function sleep(milliseconds: Int): Atom {
    NativeKernel.currentScheduler.sleep(self(), milliseconds);
    return 'ok'.atom();
  }

  public static function apply(process: Pid, ops: Array<Operation>): Void {
    var processStack = process.processStack;
    processStack.add(new DefaultAnnaCallStack(ops, processStack.getVariablesInScope()));
  }

  public static function registerPid(pid: Pid, name: Atom): Atom {
    return NativeKernel.currentScheduler.registerPid(pid, name);
  }

  public static function unregisterPid(name: Atom): Atom {
    return NativeKernel.currentScheduler.unregisterPid(name);
  }

  public static function getPidByName(name: Atom): Pid {
    return NativeKernel.currentScheduler.getPidByName(name);
  }
}
