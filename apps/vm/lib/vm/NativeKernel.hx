package vm;

import lang.macros.AnnaLang;
import project.ProjectConfig;
import vm.Pid;
import vm.Port;
import ArgHelper;
import lang.macros.MacroTools;
import core.ObjectCreator;
import EitherEnums.Either2;
import lang.EitherSupport;
import vm.Function;
import vm.schedulers.GenericScheduler;

using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
@:rtti
class NativeKernel {

  @field public static var currentScheduler: Scheduler;
  @field public static var statePid: Pid;
  @field public static var projectConfig: ProjectConfig;
  @field public static var started: Bool;
  @field public static var msg: Dynamic;

  private static var annaLang: AnnaLang;

  public static function start(): Atom {
    if(started) {
      return 'already_started'.atom();
    }
    Logger.init();
    var scheduler: vm.schedulers.CPPMultithreadedScheduler = new vm.schedulers.CPPMultithreadedScheduler();

    annaLang = new AnnaLang();

    currentScheduler = scheduler;
    currentScheduler.start();

    #if cppia
    defineCode();
    #else
    Code.defineCode();
    #end

    started = true;
    return 'ok'.atom();
  }

  private static inline function defineCode(): Atom {
    #if cppia
      var cls: Class<Dynamic> = Type.resolveClass('Code');
      if(cls == null) {
        trace('Module Code was not found');
        return 'error'.atom();
      }
      Reflect.callMethod(null, Reflect.field(cls, 'defineCode'), []);
    #end
    return 'ok'.atom();
  }

  public static function run(): Void {
    #if scriptable
    cpp.vm.Thread.create(function() {
    #end
    #if (cpp || scriptable)
    while(started) {
      if(currentScheduler.hasSomethingToExecute()) {
        for(i in 0...1000) {
          if(currentScheduler.hasSomethingToExecute() && started) {
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
    currentScheduler = null;
    statePid = null;
    Classes.clear();
    #end
    #if scriptable
    });
    #end
    #if js
    js.Node.process.nextTick(onNextTick);
    #end
  }

  #if js
  public static function onNextTick():Void {
    if(!started) {
      currentScheduler.stop();
      currentScheduler = null;
      statePid = null;
      Classes.clear();
      return;
    }
    if(currentScheduler.hasSomethingToExecute()) {
      for(i in 0...1000) {
        if(currentScheduler.hasSomethingToExecute()) {
          currentScheduler.update();
        } else {
          break;
        }
      }
    }
    js.Node.process.nextTick(onNextTick);
  }
  #end

  public static function stop(): Atom {
    if(currentScheduler != null) {
      started = false;
    }
    return 'ok'.atom();
  }

  public static function testCompiler(): Pid {
    #if startHaxe
    switchToHaxe();
    return null;
    #else
    return testSpawn('CompilerMain', 'start', []);
    #end
  }

  public static function runApplication(appName: String): Pid {
    return testSpawn(appName, 'start', []);
  }

  public static function testSpawn(module: String, func: String, args: Array<Dynamic>): Pid {
    if(!started) {
      return null;
    }
    var createArgs: Array<Tuple> = [];
    for(arg in args) {
      createArgs.push(Tuple.create(["const".atom(), arg]));
    }
    #if cpp
    //need this or we get a segfault
    Sys.sleep(0.0001);
    #end
    return currentScheduler.spawn(function() {
      return new PushStack(module.atom(), func.atom(), LList.create(cast createArgs), "Kernel".atom(), "testSpawn".atom(), MacroTools.line(), annaLang);
    });
  }

  #if cppia
  public static function restart(): Atom {
    stop();
    Sys.sleep(0.2);
    return start();
  }
  #end

  public static function recompile(): Atom {
    #if cppia
    Reflect.callMethod(null, Reflect.field(Type.resolveClass('DevelopmentRunner'), 'compileCompiler'), [function() {
      switchToIA();
    }]);
    return 'ok'.atom();
    #end
    return 'not_available'.atom();
  }

  public static function switchToIA(): Atom {
    #if cppia
    Reflect.callMethod(null, Reflect.field(Type.resolveClass('Runtime'), 'stop'), []);
    restart();
    testCompiler();
    return 'ok'.atom();
    #end
    return 'not_available'.atom();
  }

  public static function setProject(pc: ProjectConfig): Void {
    projectConfig = pc;
  }

  public static function spawn(module: Atom, func: Atom, types: Tuple, args: LList): Pid {
    func = resolveApiFuncWithTypes(func, types);
    return currentScheduler.spawn(function() {
      return new PushStack(module, func, args, "NativeKernel".atom(), "spawn".atom(), MacroTools.line(), annaLang);
    });
  }

  public static function spawnFn(fn: Function, args: LList): Pid {
    return currentScheduler.spawn(function() {
      return new InvokeAnonFunction(fn, args, 'NativeKernel'.atom(), 'spawnFn'.atom(), MacroTools.line(), annaLang);
    });
  }

  public static function spawn_linkFn(fn: Function, args: LList): Pid {
     return currentScheduler.spawnLink(Process.self(), function() {
      return new InvokeAnonFunction(fn, args, 'NativeKernel'.atom(), 'spawn_linkFn'.atom(), MacroTools.line(), annaLang);
    });
  }

  public static function spawn_link(module: Atom, func: Atom, types: Tuple, args: LList): Pid {
    func = resolveApiFuncWithTypes(func, types);
    return currentScheduler.spawnLink(Process.self(), function() {
      return new PushStack(module, func, args, "NativeKernel".atom(), "spawn_link".atom(), MacroTools.line(), annaLang);
    });
  }

  private static function resolveApiFuncWithTypes(func: Atom, types: Tuple): Atom {
    var funString: String = func.value;
    var funTypes: Array<String> = [];
    for(funType in Tuple.array(types)) {
      var strValue = cast(funType, Atom).value;
      if(strValue == 'Int' || strValue == 'Float') {
        strValue = 'Number';
      } else if(strValue == 'Function') {
        strValue = 'vm_Function';
      }
      funTypes.push(strValue);
    }
    if(funTypes.length > 0) {
      funString += '_';
    }
    return Atom.create('${funString}${funTypes.join('_')}');
  }

  public static function receive(callback: Function, timeout: Null<Int> = null): Pid {
    var pid: Pid = Process.self();
    currentScheduler.receive(pid, callback, timeout);
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

  public static function exit(pid: Pid, signal: Atom = null): Atom {
    if(signal == null) {
      signal = 'kill'.atom();
    }
    return currentScheduler.exit(pid, signal);
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

  public static function demonitor(pid: Pid): Atom {
    return currentScheduler.demonitor(Process.self(), pid);
  }

  public static inline function apply(pid: Pid, fn: Function, args: LList, callback: Dynamic->Void = null): Void {
    if(fn == null) {
      IO.inspect('NativeKernel: Function not found ${fn.apiFunc}');
      NativeKernel.crash(Process.self());
      return;
    }
    if(pid.state == ProcessState.KILLED || pid.state == ProcessState.COMPLETE) {
      IO.inspect('Pid ${Anna.toAnnaString(pid)} is not alive.');
      NativeKernel.crash(Process.self());
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
      var value: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables, annaLang);
      callArgs.push(value);
      var argName: String = fn.args[counter++];
      nextScopeVariables.set(argName, value);
    }
    currentScheduler.apply(pid, fn, callArgs, nextScopeVariables, callback);
  }

  public static inline function applyMFA(pid: Pid, module: Atom, fun: Atom, types: Tuple, args: LList, callback: Dynamic->Void = null): Void {
    fun = resolveApiFuncWithTypes(fun, types);
    var anonFn: vm.Function = Classes.getFunction(module, fun);
    if(anonFn == null) {
      IO.inspect('Function not found ${module.toAnnaString()}${fun.toAnnaString()} with args ${args.toAnnaString()}');
      NativeKernel.crash(Process.self());
      return;
    }
    anonFn.scope = new Map<String, Dynamic>();
    anonFn.apiFunc = fun;

    //todo: dry?
    if(pid.state == ProcessState.KILLED || pid.state == ProcessState.COMPLETE) {
      IO.inspect('Pid ${Anna.toAnnaString(pid)} is not alive.');
      NativeKernel.crash(Process.self());
      return;
    }
    var scopeVariables = pid.processStack.getVariablesInScope();
    var counter: Int = 0;
    var callArgs: Array<Dynamic> = [];
    var nextScopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    for(arg in LList.iterator(args)) {
      var value: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables, annaLang);
      callArgs.push(value);
      var argName: String = anonFn.args[counter++];
      nextScopeVariables.set(argName, value);
    }
    currentScheduler.apply(pid, anonFn, callArgs, nextScopeVariables, callback);
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

  public static inline function same(left: Dynamic, right: Dynamic): Atom {
    if(left == right) {
      return Atom.create('true');
    }
    return Atom.create('false');
  }

  public static inline function equal(left: Dynamic, right: Dynamic): Atom {
    var args = [left, right];
    if(areSameDataTypesEqual(args) && structuresAreEqual(args)) {
      return Atom.create('true');
    }
    return Atom.create('false');
  }

  private static inline function structuresAreEqual(args: Array<Dynamic>): Bool {
    return (Anna.toAnnaString(args[0])) == (Anna.toAnnaString(args[1]));
  }

  private static inline function areSameDataTypesEqual(args: Array<Dynamic>): Bool {
    var a: Dynamic = args[0];
    var b: Dynamic = args[1];
    return Type.typeof(a) == Type.typeof(b);
  }

}
