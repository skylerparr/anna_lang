package vm;

import cpp.vm.Thread;
import EitherEnums.Either2;
import haxe.Timer;
import lang.EitherSupport;
import util.TimeUtil;
import vm.Classes.Function;
import vm.SimpleProcess;

using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class Kernel {

  @field public static var current_id: Int;

  public static function start(): Atom {
    if(UntestedScheduler.communicationThread == null) {
      current_id = 0;
      UntestedScheduler.start();

      defineCode();

      return 'ok'.atom();
    } else {
      return 'already_started'.atom();
    }
  }

  public static function stop(): Atom {
    UntestedScheduler.stop();
    return 'ok'.atom();
  }

  public static function defineCode(): Atom {
    Classes.define("Boot".atom(), Type.resolveClass("Boot"));
    Classes.define("FunctionPatternMatching".atom(), Type.resolveClass("FunctionPatternMatching"));
    return 'ok'.atom();
  }

  public static function testSpawn(): SimpleProcess {
    Sys.sleep(0.3);
    start();
    return spawn('Boot'.atom(), 'start_'.atom(), LList.create([]));
  }

  public static function spawnCompiler(): SimpleProcess {
    Sys.sleep(0.3);
    start();
    return spawn('AnnaLangCompiler'.atom(), 'start_'.atom(), LList.create([]));
  }

  public static function spawnFunctionPatternMatch(): SimpleProcess {
    Sys.sleep(0.3);
    start();
    return spawn('FunctionPatternMatching'.atom(), 'start_'.atom(), LList.create([]));
  }

  public static function spawn(module: Atom, fun: Atom, args: LList): SimpleProcess {
    var process: SimpleProcess = new SimpleProcess(0, current_id++, 0, new PushStack(module, fun, args, "Kernel".atom(), "spawn".atom(), 51));
    UntestedScheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
    return process;
  }

  public static function receive(callback: Function): SimpleProcess {
    var process: SimpleProcess = Process.self();
    Process.waiting(process);
    UntestedScheduler.communicationThread.sendMessage(KernelMessage.RECEIVE(process, callback));
    return process;
  }

  public static function send(process: SimpleProcess, payload: Dynamic): Atom {
    UntestedScheduler.communicationThread.sendMessage(KernelMessage.SEND(process, payload));
    return 'ok'.atom();
  }

  public static function apply(process: SimpleProcess, fn: Function, args: LList, callback: Dynamic->Void = null): Void {
    if(fn == null) {
      //TODO: handle missing function error
      Logger.inspect('throw a crazy error and kill the process!');
      return;
    }
    var scopeVariables = process.processStack.getVariablesInScope();
    var counter: Int = 0;
    var callArgs: Array<Dynamic> = [];
    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(key in scopeVariables.keys()) {
      nextScopeVariables.set(key, scopeVariables.get(key));
    }
    for(arg in LList.iterator(args)) {
      var tuple: Tuple = EitherSupport.getValue(arg);
      var argArray = tuple.asArray();
      var elem1: Either2<Atom, Dynamic> = argArray[0];
      var elem2: Either2<Atom, Dynamic> = argArray[1];

      var value: Dynamic = switch(cast(EitherSupport.getValue(elem1), Atom)) {
        case {value: 'const'}:
          EitherSupport.getValue(elem2);
        case {value: 'var'}:
          var varName: String = EitherSupport.getValue(elem2);
          scopeVariables.get(varName);
        case _:
          Logger.inspect("!!!!!!!!!!! bad !!!!!!!!!!!");
          null;
      }
      callArgs.push(value);
      var argName: String = fn.args[counter++];
      nextScopeVariables.set(argName, value);
    }

    var operations: Array<Operation> = Reflect.callMethod(null, fn.fn, callArgs);
    if(callback != null) {
      var op = new InvokeCallback(callback, "Kernel".atom(), "apply".atom(), 105);
      operations.push(op);
    }
    var annaCallStack: AnnaCallStack = new AnnaCallStack(operations, nextScopeVariables);
    process.processStack.add(annaCallStack);
  }

  public static function add(left: Float, right: Float): Float {
    return left + right;
  }

  public static function subtract(left: Float, right: Float): Float {
    return left - right;
  }

}