package vm;
import cpp.vm.Thread;
using lang.AtomSupport;

import lang.CustomTypes.CustomType;
class Process implements CustomType {
  public var server_id(default, never): Int;
  public var instance_id(default, never): Int;
  public var group_id(default, never): Int;
  public var processStack(default, never): ProcessStack;
  public var status(default, never): ProcessState;
  public var thread(default, never): Thread;

  public inline function new(server_id: Int, instance_id: Int, group_id: Int, stack: AnnaCallStack) {
    var processStack: ProcessStack = new ProcessStack(this);
    processStack.add(stack);
    
    Reflect.setField(this, 'server_id', server_id);
    Reflect.setField(this, 'instance_id', instance_id);
    Reflect.setField(this, 'group_id', group_id);
    Reflect.setField(this, 'processStack', processStack);
    Reflect.setField(this, 'status', ProcessState.READY);
  }

  public function toAnnaString(): String {
    return '#PID<${server_id}.${group_id}.${instance_id}>';
  }

  public function toHaxeString(): String {
    return '';
  }

  public function toPattern(patternArgs: Array<KeyValue<String,String>> = null): String {
    return '';
  }

  public static function stop(): Atom {
    return 'not implemented'.atom();
  }

  public static function running(process: Process): Atom {
    Reflect.setField(process, 'status', ProcessState.RUNNING);
    return 'ok'.atom();
  }

  public static function complete(process: Process): Atom {
    var process: Process = self();
    Reflect.setField(process, 'status', ProcessState.COMPLETE);
    return 'ok'.atom();
  }

  public static function self(): Process {
    var process: Process = Scheduler.threadProcessMap.get(Thread.current().handle);
    return process;
  }

  public static function sleep(milliseconds: Int): Atom {
    var process: Process = self();
    Reflect.setField(process, 'status', ProcessState.SLEEPING);
    Scheduler.sleep(process, milliseconds);
    return 'ok'.atom();
  }
}