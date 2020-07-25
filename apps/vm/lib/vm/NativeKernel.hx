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
import org.hxbert.BERT;
import project.AnnaLangProject;

@:rtti
class NativeKernel {

  public static var currentScheduler: Scheduler;
  public static var statePid: Pid;
  public static var projectConfig: ProjectConfig;
  public static var started: Bool;
  public static var msg: Dynamic;

  private static var annaLang: AnnaLang;
  private static var annaLangProject: AnnaLangProject;

  public static function start(): Atom {
    if(started) {
      return Atom.create("already_started");
    }
    Logger.init();
    var scheduler: vm.schedulers.CPPMultithreadedScheduler = new vm.schedulers.CPPMultithreadedScheduler();

    annaLang = new AnnaLang();

    currentScheduler = scheduler;
    currentScheduler.start();

    Code.defineCode();

    started = true;
    return Atom.create("ok");
  }

  public static function run(): Void {
    #if cpp
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
    return Atom.create('ok');
  }

  public static function testCompiler(): Pid {
    return testSpawn('CompilerMain', 'start', []);
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
      createArgs.push(Tuple.create([Atom.create("const"), arg]));
    }
    #if cpp
    //need this or we get a segfault
    Sys.sleep(0.0001);
    #end
    return currentScheduler.spawn(function() {
      return new PushStack(Atom.create(module), Atom.create(func), LList.create(cast createArgs), Atom.create("Kernel"), Atom.create("testSpawn"), MacroTools.line(), annaLang);
    });
  }

  public static function setProject(pc: ProjectConfig): Void {
    projectConfig = pc;
  }

  public static function setAnnaLangProject(ap: AnnaLangProject): Void {
    annaLangProject = ap;
  }

  public static function getAutoStart(): Atom {
    return Atom.create(annaLangProject.autoStart);
  }
  
  public static function getAutoStartPath(): String {
    var autoStart: String = util.StringUtil.toSnakeCase(annaLangProject.autoStart); 
    return '${annaLangProject.srcDir}${autoStart}.anna';
  }

  public static function spawn(module: Atom, func: Atom, types: Tuple, args: LList): Pid {
    func = resolveApiFuncWithTypes(func, types);
    return currentScheduler.spawn(function() {
      return new PushStack(module, func, args, Atom.create("NativeKernel"), Atom.create("spawn"), MacroTools.line(), annaLang);
    });
  }

  public static function spawnFn(fn: Function, args: LList): Pid {
    return currentScheduler.spawn(function() {
      return new InvokeAnonFunction(fn, args, Atom.create("NativeKernel"), Atom.create("spawnFn"), MacroTools.line(), annaLang);
    });
  }

  public static function spawn_linkFn(fn: Function, args: LList): Pid {
     return currentScheduler.spawnLink(Process.self(), function() {
      return new InvokeAnonFunction(fn, args, Atom.create("NativeKernel"), Atom.create("spawn_linkFn"), MacroTools.line(), annaLang);
    });
  }

  public static function spawn_link(module: Atom, func: Atom, types: Tuple, args: LList): Pid {
    func = resolveApiFuncWithTypes(func, types);
    return currentScheduler.spawnLink(Process.self(), function() {
      return new PushStack(module, func, args, Atom.create("NativeKernel"), Atom.create("spawn_link"), MacroTools.line(), annaLang);
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
    return Atom.create("ok");
  }

  public static function crash(pid: Pid): Atom {
    Logger.inspect("*** EXIT ***");
    Logger.inspect(pid);
    Process.printStackTrace(pid);
    Logger.inspect("************");
    return currentScheduler.exit(pid, Atom.create("crash"));
  }

  public static function exit(pid: Pid, signal: Atom = null): Atom {
    if(signal == null) {
      signal = Atom.create("kill");
    }
    return currentScheduler.exit(pid, signal);
  }

  public static function trapExit(pid: Pid): Atom {
    return currentScheduler.flag(pid, Atom.create("trap_exit"), Atom.create("true"));
  }

  public static function untrapExit(pid: Pid): Atom {
    return currentScheduler.flag(pid, Atom.create("trap_exit"), Atom.create("false"));
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

  public static inline function add(left: Null<Float>, right: Null<Float>): Float {
    return left + right;
  }

  public static inline function subtract(left: Null<Float>, right: Null<Float>): Float {
    return left - right;
  }

  public static inline function mult(left: Null<Float>, right: Null<Float>): Float {
    return left * right;
  }

  public static inline function div(left: Null<Float>, right: Null<Float>): Float {
    return left / right;
  }

  public static inline function greaterThan(left: Null<Float>, right: Null<Float>): Atom {
    if(left > right) {
      return Atom.create('true');
    } else {
      return Atom.create('false');
    }
  }

  public static inline function greaterThanOrEqual(left: Null<Float>, right: Null<Float>): Atom {
    if(left >= right) {
      return Atom.create('true');
    } else {
      return Atom.create('false');
    }
  }

  public static inline function lessThan(left: Null<Float>, right: Null<Float>): Atom {
    if(left < right) {
      return Atom.create('true');
    } else {
      return Atom.create('false');
    }
  }
 
  public static inline function lessThanOrEqual(left: Null<Float>, right: Null<Float>): Atom {
    if(left <= right) {
      return Atom.create('true');
    } else {
      return Atom.create('false');
    }
  }
   
  public static inline function mod(left: Null<Float>, right: Null<Float>): Float {
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

  public static inline function termToBinary(term: Any): Binary {
    return Anna.termToBinary(term);
  }
  
  public static inline function binaryToTerm(bin: Binary): Dynamic {
    return Anna.binaryToTerm(bin);
  }

}
