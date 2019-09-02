package vm.schedulers;

import Tuple.Tuple2;
import EitherEnums.Either1;
using lang.AtomSupport;

class GenericScheduler implements Scheduler {

  public function start(): Atom {
    return "ok".atom();
  }

  public function pause(): Atom {
    return "ok".atom();
  }

  public function resume(): Atom {
    return "ok".atom();
  }

  public function stop(): Atom {
    return "ok".atom();
  }

  public function sleep(pid: Pid, milliseconds: Float): Pid {
    return null;
  }

  public function send(pid: Pid, payload: Dynamic): Atom {
    return "ok".atom();
  }

  public function receive(process: Pid, callback: (Dynamic) -> Void, timeout: Float = -1): Void {
  }

  public function update(): Void {
  }

  public function spawn(fn: Void->Dynamic): Pid {
    return null;
  }

  public function spawn_link(fn: Void->Dynamic): Tuple2<Either1<Atom>, Either1<String>> {
    return null;
  }

  public function monitor(pid: Pid): Atom {
    return "ok".atom();
  }

  public function demonitor(pid: Pid): Atom {
    return "ok".atom();
  }

  public function flag(pid: Pid, flag: Atom, value: Atom): Atom {
    return "ok".atom();
  }

  public function exit(pid: Pid, signal: Atom): Atom {
    return "ok".atom();
  }

  public function apply(fn: Dynamic, onComplete: (Dynamic) -> Void): Void {
  }
}