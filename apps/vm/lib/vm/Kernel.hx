package vm;

import cpp.vm.Thread;
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
  @field public static var thread: Thread;

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
    if(currentScheduler != null) {
      thread.sendMessage(false);
      currentScheduler.stop();
    }
    return 'ok'.atom();
  }

  public static function defineCode(): Atom {
    Classes.define("Boot".atom(), Type.resolveClass("Boot"));
    Classes.define("FunctionPatternMatching".atom(), Type.resolveClass("FunctionPatternMatching"));
    return 'ok'.atom();
  }

  public static function testGenericScheduler(): Atom {
    defineCode();
    var scheduler: GenericScheduler = new GenericScheduler();
    ObjectFactory.injector.mapClass(Pid, SimpleProcess);
    scheduler.objectCreator = cast ObjectFactory.injector.getInstance(ObjectCreator);
    currentScheduler = scheduler;
    currentScheduler.start();

    currentScheduler.spawn(function() {
      return new PushStack('Boot'.atom(), 'start_'.atom(), LList.create([]), "Kernel".atom(), "testGenericScheduler".atom(), MacroTools.line());
    });

    return "ok".atom();
  }

  public static function update(): Void {
    var counter: Int = 1000;
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
    var process: SimpleProcess = new SimpleProcess();
    process.start(new PushStack(module, fun, args, "Kernel".atom(), "spawn".atom(), 51));
    UntestedScheduler.communicationThread.sendMessage(KernelMessage.SCHEDULE(process));
    return process;
  }

  public static function receive(callback: Function): Pid {
    var process: Pid = Process.self();
    Process.waiting(process);
    UntestedScheduler.communicationThread.sendMessage(KernelMessage.RECEIVE(process, callback));
    return process;
  }

  public static function send(process: Pid, payload: Dynamic): Atom {
    UntestedScheduler.communicationThread.sendMessage(KernelMessage.SEND(process, payload));
    return 'ok'.atom();
  }

  public static function apply(process: Pid, fn: Function, args: LList, callback: Dynamic->Void = null): Void {
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

    var operations: Array<Operation> = fn.invoke(callArgs);
    if(callback != null) {
      var op = new InvokeCallback(callback, "Kernel".atom(), "apply".atom(), 105);
      operations.push(op);
    }
    var annaCallStack: AnnaCallStack = new DefaultAnnaCallStack(operations, nextScopeVariables);
    process.processStack.add(annaCallStack);
  }

  public static function add(left: Float, right: Float): Float {
    return left + right;
  }

  public static function subtract(left: Float, right: Float): Float {
    return left - right;
  }

}