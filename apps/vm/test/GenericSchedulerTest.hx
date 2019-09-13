package ;

import core.ObjectCreator;
import vm.ProcessState;
import vm.DefaultProcessStack;
import vm.Pid;
import vm.schedulers.GenericScheduler;
import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;
@:build(lang.macros.Macros.build())
class GenericSchedulerTest {
  private static var scheduler: GenericScheduler;
  private static var objectCreator: ObjectCreator;

  public static function setup(): Void {
    scheduler = new GenericScheduler();
    objectCreator = mock(ObjectCreator);
  }

  public static function shouldReturnOkWhenStartingScheduler(): Void {
    @assert scheduler.start() == @_"ok";
  }

  public static function shouldReturnAlreadyStartedIfSchedulerIsAlreadyRunning(): Void {
    @assert scheduler.start() == @_"ok";
    @assert scheduler.start() == @_"already_started";
  }

  public static function shouldSpawnProcess(): Void {
    scheduler.start();
    var pid: Pid = mock(Pid);
    scheduler.spawn(function(): Dynamic {
      return "";
    });
  }
}