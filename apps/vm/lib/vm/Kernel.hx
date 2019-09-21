package vm;

import util.ArgHelper;
import lang.macros.MacroTools;
import core.ObjectCreator;
import core.ObjectFactory;
import EitherEnums.Either2;
import lang.EitherSupport;
import vm.Function;
import vm.schedulers.GenericScheduler;

using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class Kernel {

  @field public static var current_id: Int;
  @field public static var currentScheduler: Scheduler;

  public static function start(): Atom {
    current_id = 0;
    defineCode();
    return 'ok'.atom();
  }

  public static function stop(): Atom {
    if(currentScheduler != null) {
      currentScheduler.stop();
    }
    return 'ok'.atom();
  }

  public static function defineCode(): Atom {
    Classes.define("Boot".atom(), Type.resolveClass("Boot"));
    Classes.define("FunctionPatternMatching".atom(), Type.resolveClass("FunctionPatternMatching"));
    return 'ok'.atom();
  }

  public static function testGenericScheduler(): Pid {
    defineCode();
    var scheduler: GenericScheduler = new GenericScheduler();
    ObjectFactory.injector.mapClass(Pid, SimpleProcess);
    scheduler.objectCreator = cast ObjectFactory.injector.getInstance(ObjectCreator);
    currentScheduler = scheduler;
    currentScheduler.start();

    return currentScheduler.spawn(function() {
      return new PushStack('Boot'.atom(), 'start'.atom(), LList.create([]), "Kernel".atom(), "testGenericScheduler".atom(), MacroTools.line());
    });
  }

  public static function update(): Void {
    var counter: Int = 100;
    while(counter > 0) {
      counter--;
      currentScheduler.update();
    }
  }

  public static function testSpawn(): Pid {
    start();
    return spawn('Boot'.atom(), 'start_'.atom(), LList.create([]));
  }

  public static function spawnCompiler(): Pid {
    start();
    return spawn('AnnaLangCompiler'.atom(), 'start_'.atom(), LList.create([]));
  }

  public static function spawnFunctionPatternMatch(): Pid {
    start();
    return spawn('FunctionPatternMatching'.atom(), 'start_'.atom(), LList.create([]));
  }

  public static function spawn(module: Atom, fun: Atom, args: LList): Pid {
    return currentScheduler.spawn(function() {
      return new PushStack('Boot'.atom(), 'start'.atom(), LList.create([]), "Kernel".atom(), "testGenericScheduler".atom(), MacroTools.line());
    });
  }

  public static function receive(callback: Function): Pid {
    var pid: Pid = Process.self();
    currentScheduler.receive(pid, callback);
    return pid;
  }

  public static function send(pid: Pid, payload: Dynamic): Atom {
    currentScheduler.send(pid, payload);
    return 'ok'.atom();
  }

  public static function apply(pid: Pid, fn: Function, args: LList, callback: Dynamic->Void = null): Void {
    if(fn == null) {
      //TODO: handle missing function error
      Logger.inspect('throw a crazy error and kill the process!');
      return;
    }
    var scopeVariables = pid.processStack.getVariablesInScope();
    var counter: Int = 0;
    var callArgs: Array<Dynamic> = [];
    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(key in scopeVariables.keys()) {
      nextScopeVariables.set(key, scopeVariables.get(key));
    }
    for(arg in LList.iterator(args)) {
      var value: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables);
      callArgs.push(value);
      var argName: String = fn.args[counter++];
      nextScopeVariables.set(argName, value);
    }

    currentScheduler.apply(pid, fn, callArgs, nextScopeVariables, callback);
  }

  public static function add(left: Float, right: Float): Float {
    return left + right;
  }

  public static function subtract(left: Float, right: Float): Float {
    return left - right;
  }

}