package vm.schedulers;
import haxe.macro.Expr;
class ThreadMessageReader {
  macro public static function readMessages(scheduler: Expr): Expr {
    return macro {
      while(true) {
        var message: KernelMessage = Thread.readMessage(false);
        if(message == null) {
          break;
        } else {
          switch(message) {
            case SEND(pid, payload):
              $e{scheduler}.send(pid, payload);
            case RECEIVE(pid, fn, timeout, callback):
              $e{scheduler}.receive(pid, fn, timeout, callback);
            case APPLY(pid, fn, args, scopeVariables, callback):
              $e{scheduler}.apply(pid, fn, args, scopeVariables, callback);
            case SPAWN(fn, respondThread):
              var response = $e{scheduler}.spawn(fn);
              respondThread.sendMessage(response);
            case SPAWN_LINK(parentPid, fn, respondThread):
              var response = $e{scheduler}.spawnLink(parentPid, fn);
              respondThread.sendMessage(response);
            case SLEEP(pid, milliseconds):
              $e{scheduler}.sleep(pid, milliseconds);
            case EXIT(pid, signal, respondThread):
              var response = $e{scheduler}.exit(pid, signal);
              respondThread.sendMessage(response);
            case MONITOR(parentPid, pid):
              scheduler.monitor(parentPid, pid);
            case DEMONITOR(parentPid, pid):
              scheduler.demonitor(parentPid, pid);
            case STOP:
              running = false;
              $e{scheduler}.stop();
              return;
            case _:
          }
        }
      }

    }
  }
}
