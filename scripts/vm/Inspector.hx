package vm;
import cpp.vm.Thread;
@:build(lang.macros.ValueClassImpl.build())
class Inspector {
  @field public static var debugThread: Thread;
  @field public static var stopped: Bool;
  @field public static var ttyThread: Thread;

  public static function resume(): Void {
    if(debugThread == null) {
      Logger.inspect("Nothing to inspect.");
      return;
    }
    debugThread.sendMessage(DebugMessage.RESUME);
  }

  public static function printVar(name: String): Void {
    if(debugThread == null) {
      Logger.inspect("Nothing to inspect.");
      return;
    }
    debugThread.sendMessage(DebugMessage.PRINT_VAR(name));
  }

  public static function getValue(name: String): Dynamic {
    if(debugThread == null) {
      Logger.inspect("Nothing to inspect.");
      return null;
    }
    debugThread.sendMessage(DebugMessage.GET_VAR(name, Thread.current()));
    return Thread.readMessage(true);
  }

  public static function listVars(): Void {
    if(debugThread == null) {
      Logger.inspect("Nothing to inspect.");
      return;
    }
    debugThread.sendMessage(DebugMessage.LIST_VARS);
  }

  public static function whereAmI(): Void {
    if(debugThread == null) {
      Logger.inspect("Lost in your thoughts...");
      return;
    }
    debugThread.sendMessage(DebugMessage.CURRENT_POS);
  }

  public static function stop(): Void {
    if(debugThread == null) {
      Logger.inspect("Nothing to inspect.");
      return;
    }
    stopped = true;
    Logger.inspect("Inspector stopped.");
    debugThread.sendMessage(DebugMessage.RESUME);
  }

  public static function start(): Void {
    stopped = false;
    if(Std.int(Math.random() * 10) == 5) {
      Logger.inspect("With great power comes great responsiblity, use with care...");
    } else {
      Logger.inspect("Inspector running...");
    }
  }

}
