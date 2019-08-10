package vm;

import lib.Modules;
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
    Classes.define("CallCounter".atom(), Modules);
    Classes.define("Boot".atom(), Boot);
    return 'ok'.atom();
  }

  public static function testSpawn(): Process {
    Inspector.ttyThread = Thread.current();
    stop();
    Native.callStatic('Runtime', 'recompile', []);
    start();
    return spawn('Boot'.atom(), 'start_'.atom(), LList.create([]));
  }

  public static function spawn(module: Atom, fun: Atom, args: LList): Process {
    var process: Process = new Process(0, current_id++, 0, new PushStack(module, fun, args, "Kernel".atom(), "spawn".atom(), 51));
    Scheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
    return process;
  }

  public static function receive(matcher: Dynamic): Process {
    Logger.inspect(matcher);
    var process: Process = Process.self();
    Scheduler.communicationThread.sendMessage(KernelMessage.RECEIVE(process, matcher));
    return process;
  }

  public static function send(process: Process, payload: Dynamic): Atom {
    Scheduler.communicationThread.sendMessage(KernelMessage.SEND(process, payload));
    return 'ok'.atom();
  }

  public static function add(left: Float, right: Float): Float {
    return left + right;
  }

}