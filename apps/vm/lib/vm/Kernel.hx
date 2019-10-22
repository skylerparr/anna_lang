package vm;

import project.ProjectConfig;
import vm.Pid;
import cpp.vm.Thread;
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
  @field public static var loopingThread: Thread;
  @field public static var statePid: Pid;
  @field public static var projectConfig: ProjectConfig;

  public static function start(): Atom {
    if(loopingThread != null) {
      return 'already_started'.atom();
    }
    current_id = 0;
    defineCode();
    var scheduler: GenericScheduler = new GenericScheduler();
    ObjectFactory.injector.mapClass(Pid, SimpleProcess);
    scheduler.objectCreator = cast ObjectFactory.injector.getInstance(ObjectCreator);
    currentScheduler = scheduler;
    currentScheduler.start();
    var parentThread: Thread = Thread.current();
    loopingThread = Thread.create(function() {
      while(true) {
        var msg: Dynamic = Thread.readMessage(false);
        if(msg == 'stop'.atom()) {
          break;
        }
        if(msg != null) {
          var pid: Pid = msg();
          parentThread.sendMessage(pid);
        }
        Sys.sleep(0.0001);
        if(currentScheduler.hasSomethingToExecute()) {
          for(i in 0...1000) {
            if(currentScheduler.hasSomethingToExecute()) {
              currentScheduler.update();
            } else {
              break;
            }
          }
        } else {
          Sys.sleep(0.1);
        }
      }
      currentScheduler.stop();
      loopingThread = null;
      currentScheduler = null;
      statePid = null;
      Classes.clear();
    });
    return 'ok'.atom();
  }

  public static function stop(): Atom {
    if(currentScheduler != null) {
      loopingThread.sendMessage('stop'.atom());
    }
    return 'ok'.atom();
  }

  public static function restart(): Atom {
    stop();
    Sys.sleep(0.2);
    return start();
  }

  public static function defineCode(): Atom {
//    Classes.define("Boot".atom(), Type.resolveClass("Boot"));
//    Classes.define("FunctionPatternMatching".atom(), Type.resolveClass("FunctionPatternMatching"));
    Classes.define("CompilerMain".atom(), Type.resolveClass("CompilerMain"));
    Classes.define("Str".atom(), Type.resolveClass("Str"));
    Classes.define("System".atom(), Type.resolveClass("System"));
    Classes.define("CommandHandler".atom(), Type.resolveClass("CommandHandler"));
    return 'ok'.atom();
  }

  public static function testCompiler(): Pid {
    return testSpawn('CompilerMain', 'start', []);
  }

  public static function testGenericScheduler(): Pid {
    return testSpawn('Boot', 'start', []);
  }

  public static function testReceiveMessage(): Pid {
    return testSpawn('Boot', 'test_receive', []);
  }

  public static function testInfiniteLoop(): Pid {
    return testSpawn('Boot', 'start_infinite_loop', []);
  }

  public static function testStoreState(): Pid {
    return testSpawn('Boot', 'start_state', []);
  }

  public static function testDSWithVars(): Pid {
    return testSpawn('Boot', 'test_ds_with_vars', []);
  }

  public static function testCountForever(): Pid {
    return testSpawn('Boot', 'count_forever', []);
  }

  public static function incrementState(pid: Pid): Pid {
    return testSpawn('Boot', 'increment_state_vm_Pid', [pid]);
  }

  public static function testExitPid(pid: Pid): Pid {
    return testSpawn('Boot', 'exit_vm_Pid', [pid]);
  }

  public static function testTrapExit(pid: Pid): Pid {
    return testSpawn('Boot', 'trap_exit_vm_Pid', [pid]);
  }

  public static function testUntrapExit(pid: Pid): Pid {
    return testSpawn('Boot', 'untrap_exit_vm_Pid', [pid]);
  }

  public static function getPidState(pid: Pid): Pid {
    return testSpawn('Boot', 'get_state_vm_Pid', [pid]);
  }

  public static function testMonitor(): Pid {
    return testSpawn('Boot', 'test_monitor', []);
  }

  public static function saveState(pid: Pid): Pid {
    statePid = pid;
    return pid;
  }

  public static function testSpawn(module: String, func: String, args: Array<Dynamic>): Pid {
    if(loopingThread == null) {
      return null;
    }
    loopingThread.sendMessage(function() {
      var createArgs: Array<Tuple> = [];
      for(arg in args) {
        createArgs.push(Tuple.create(["const".atom(), arg]));
      }
      return currentScheduler.spawn(function() {
        return new PushStack(module.atom(), func.atom(), LList.create(cast createArgs), "Kernel".atom(), "testSpawn".atom(), MacroTools.line());
      });
    });
    return Thread.readMessage(true);
  }

  public static function recompile(): Atom {
    var mainThread: Thread = Thread.current();
    Thread.create(function() {
      Reflect.callMethod(null, Reflect.field(Type.resolveClass('Runner'), 'compileCompiler'), [function() {
        switchToIA();
      }]);
    });
    return 'ok'.atom();
  }

  public static function compileVM(): Atom {
    var mainThread: Thread = Thread.current();
    Thread.create(function() {
      Reflect.callMethod(null, Reflect.field(Type.resolveClass('Runner'), 'compileVMProject'), [function() {
        recompile();
      }]);
    });
    return 'ok'.atom();
  }

  public static function switchToHaxe(): Atom {
    Thread.create(function() {
      Reflect.callMethod(null, Reflect.field(Type.resolveClass('Runtime'), 'start'), []);
    });
    return 'ok'.atom();
  }

  public static function switchToIA(): Atom {
    Reflect.callMethod(null, Reflect.field(Type.resolveClass('Runtime'), 'stop'), []);
    restart();
    testCompiler();
    return 'ok'.atom();
  }

  public static function setProject(pc: ProjectConfig): Void {
    projectConfig = pc;
  }

  public static function spawn(module: Atom, func: Atom, types: Tuple, args: LList): Pid {
    return currentScheduler.spawn(function() {
      return new PushStack(module, func, args, "Kernel".atom(), "spawn".atom(), MacroTools.line());
    });
  }

  public static function update(): Void {
    var counter: Int = 100;
    while(counter > 0) {
      counter--;
      currentScheduler.update();
    }
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

  public static function crash(pid: Pid): Atom {
    Logger.inspect("*** EXIT ***");
    Logger.inspect(pid);
    Process.printStackTrace(pid);
    Logger.inspect("************");
    return currentScheduler.exit(pid, 'crash'.atom());
  }

  public static function exit(pid: Pid): Atom {
    return currentScheduler.exit(pid, 'kill'.atom());
  }

  public static function trapExit(pid: Pid): Atom {
    return currentScheduler.flag(pid, 'trap_exit'.atom(), 'true'.atom());
  }

  public static function untrapExit(pid: Pid): Atom {
    return currentScheduler.flag(pid, 'trap_exit'.atom(), 'false'.atom());
  }

  public static function monitor(pid: Pid): Atom {
    return currentScheduler.monitor(Process.self(), pid);
  }

  public static function apply(pid: Pid, fn: Function, args: LList, callback: Dynamic->Void = null): Void {
    if(fn == null) {
      //TODO: handle missing function error
      Logger.inspect('throw a crazy error and kill the process!');
      return;
    }
    if(pid.state == ProcessState.KILLED || pid.state == ProcessState.COMPLETE) {
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

  public static inline function isNull(val: Dynamic): Bool {
    return val == null;
  }

  public static function add(left: Float, right: Float): Float {
    return left + right;
  }

  public static function subtract(left: Float, right: Float): Float {
    return left - right;
  }

  public static function mult(left: Float, right: Float): Float {
    return left * right;
  }

  public static function div(left: Float, right: Float): Float {
    return left / right;
  }

  public static function mod(left: Float, right: Float): Float {
    return left % right;
  }

  public static function concat(lhs: String, rhs: String): String {
    return lhs + rhs;
  }
}