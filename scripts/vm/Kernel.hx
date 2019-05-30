package vm;

import cpp.vm.Thread;
import vm.Process;

using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class Kernel {

  @field public static var current_id: Int;

  public static function start(): Atom {
    if(Scheduler.communicationThread == null) {
      current_id = 0;
      Scheduler.start();
      if(Counter.increment == null) {
        Counter._increment();
      }
      return 'ok'.atom();
    } else {
      return 'already_started'.atom();
    }
  }

  public static function stop(): Atom {
    Scheduler.stop();
    return 'ok'.atom();
  }

  public static function testSpawn(): Void {
    var process: Process;
    process = spawn(new AnnaCallStack(Counter.increment));
  }

  public static function spawn(annaCallStack: AnnaCallStack): Process {
    var process: Process = new Process(0, current_id++, 0, annaCallStack);
    Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
    return process;
  }

  public static function sleep(process: Process, callback: Void -> Void): Void {
    Reflect.setField(process, 'func', callback);
    Reflect.setField(process, 'status', ProcessState.SLEEPING);
    Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
  }

  public static function send(process: Process, payload: Dynamic): Tuple {
    return Tuple.create(['error'.atom(), 'Not implemented yet']);
  }

  public static function add(left: Int, right: Int): Int {
    return left + right;
  }

}