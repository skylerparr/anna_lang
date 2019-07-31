package vm;

import lib.Modules;
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
    Classes.define("CallCounter".atom(), Modules);
//    Classes.define("Boot".atom(), Boot);
    return 'ok'.atom();
  }

  public static function testSpawn(): Process {
    Inspector.ttyThread = Thread.current();
    stop();
    Native.callStatic('Runtime', 'recompile', []);
    start();
//    return spawn('Boot'.atom(), 'start_'.atom(), LList.create([]));
    return null;
  }

  public static function spawn(module: Atom, fun: Atom, args: LList): Process {
    var process: Process = new Process(0, current_id++, 0, new PushStack(module, fun, args, "Kernel".atom(), "spawn".atom(), 51));
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