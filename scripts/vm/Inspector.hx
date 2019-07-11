package vm;
import cpp.vm.Thread;
@:build(lang.macros.ValueClassImpl.build())
class Inspector {
  @field public static var debugThread: Thread;
  @field public static var paused: Bool;

  public static function resume(): Void {
    if(debugThread == null) {
      Logger.inspect("Nothing to debug.");
      return;
    }
    debugThread.sendMessage(DebugMessage.RESUME);
  }

  public static function printVar(name: String): Void {
    if(debugThread == null) {
      Logger.inspect("Nothing to debug.");
      return;
    }
    debugThread.sendMessage(DebugMessage.PRINT_VAR(name));
  }

  public static function getValue(name: String): Dynamic {
    if(debugThread == null) {
      Logger.inspect("Nothing to debug.");
      return null;
    }
    debugThread.sendMessage(DebugMessage.GET_VAR(name, Thread.current()));
    return Thread.readMessage(true);
  }

  public static function listVars(): Void {
    if(debugThread == null) {
      Logger.inspect("Nothing to debug.");
      return;
    }
    debugThread.sendMessage(DebugMessage.LIST_VARS);
  }

  public static function pause(): Void {
    if(debugThread == null) {
      Logger.inspect("Nothing to debug.");
      return;
    }
    paused = true;
    debugThread.sendMessage(DebugMessage.RESUME);
    Logger.inspect("Debugger paused");
  }

  public static function unPause(): Void {
    paused = false;
    Logger.inspect("Debugger unpaused");
  }

}
