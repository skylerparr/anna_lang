package vm;

import lib.CallCounter;
import lib.Counter;
import compiler.Compiler;
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

      Compiler.subscribeAfterCompile(defineCode);
      defineCode();

      return 'ok'.atom();
    } else {
      return 'already_started'.atom();
    }
  }

  public static function stop(): Atom {
    Scheduler.stop();
    return 'ok'.atom();
  }

  public static function defineCode(): Atom {
    Classes.define("Counter".atom(), Counter);
    Classes.define("CallCounter".atom(), CallCounter);
    return 'ok'.atom();
  }

  public static function testSpawn(): Process {
    start();
    return spawn(new AnnaCallStack(CallCounter.invoke(), new Map<String , Dynamic>()));
  }

  public static function spawn(annaCallStack: AnnaCallStack): Process {
    var process: Process = new Process(0, current_id++, 0, annaCallStack);
    Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
    return process;
  }

  public static function send(process: Process, payload: Dynamic): Tuple {
    return Tuple.create(['error'.atom(), 'Not implemented yet']);
  }

  public static function add(left: Int, right: Int): Int {
    return left + right;
  }

}