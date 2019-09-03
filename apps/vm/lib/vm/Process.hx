package vm;
import cpp.vm.Thread;
import vm.Classes.Function;
using lang.AtomSupport;
class Process {
  public static function putInMailbox(process: SimpleProcess, value: Dynamic): Void {
    process.mailbox.push(value);
  }

  public static function printStackTrace(process: SimpleProcess): Void {
    process.processStack.printStackTrace();
  }

  public static function isAlive(process: SimpleProcess): Atom {
    return switch(process.state) {
      case ProcessState.COMPLETE | ProcessState.KILLED:
        'false'.atom();
      case _:
        'true'.atom();
    }
  }

  public static function exit(process: SimpleProcess): Atom {
    Reflect.setField(process, 'state', ProcessState.KILLED);
    return 'ok'.atom();
  }

  public static function running(process: SimpleProcess): Atom {
    Reflect.setField(process, 'state', ProcessState.RUNNING);
    return 'ok'.atom();
  }

  public static function complete(process: SimpleProcess): Atom {
    Reflect.setField(process, 'state', ProcessState.COMPLETE);
    return 'ok'.atom();
  }

  public static function waiting(process: SimpleProcess): Atom {
    Reflect.setField(process, 'state', ProcessState.WAITING);
    return 'ok'.atom();
  }

  public static function receive(process: SimpleProcess, callback: Function): Atom {
    UntestedScheduler.receive(process, callback);
    return 'ok'.atom();
  }

  public static function self(): SimpleProcess {
    var process: SimpleProcess = UntestedScheduler.threadProcessMap.get(Thread.current().handle);
    return process;
  }

  public static function sleep(milliseconds: Int): Atom {
    var process: SimpleProcess = self();
    Reflect.setField(process, 'state', ProcessState.SLEEPING);
    UntestedScheduler.sleep(process, milliseconds);
    return 'ok'.atom();
  }

  public static function apply(process: SimpleProcess, ops: Array<Operation>): Void {
    var processStack = process.processStack;
    processStack.add(new AnnaCallStack(ops, processStack.getVariablesInScope()));
  }
}
