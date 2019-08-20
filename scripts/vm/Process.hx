package vm;
import haxe.DynamicAccess;
import vm.Classes.Function;
import cpp.vm.Thread;
using lang.AtomSupport;

import lang.CustomTypes.CustomType;
class Process implements CustomType {
  public var server_id(default, never): Int;
  public var instance_id(default, never): Int;
  public var group_id(default, never): Int;
  public var processStack(default, never): ProcessStack;
  public var state(default, never): ProcessState;
  public var thread(default, never): Thread;
  public var mailbox(default, never): Array<Dynamic>;

  public inline function new(server_id: Int, instance_id: Int, group_id: Int, op: Operation) {
    var processStack: ProcessStack = new ProcessStack(this);
    processStack.add(new AnnaCallStack([op], new Map<String, Dynamic>()));

    Reflect.setField(this, 'server_id', server_id);
    Reflect.setField(this, 'instance_id', instance_id);
    Reflect.setField(this, 'group_id', group_id);
    Reflect.setField(this, 'processStack', processStack);
    Reflect.setField(this, 'state', ProcessState.RUNNING);
    Reflect.setField(this, 'mailbox', []);
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

  public static function putInMailbox(process: Process, value: Dynamic): Void {
    process.mailbox.push(value);
  }

  public static function printStackTrace(process: Process): Void {
    process.processStack.printStackTrace();
  }

  public static function isAlive(process: Process): Atom {
    return switch(process.state) {
      case ProcessState.COMPLETE | ProcessState.KILLED:
        'false'.atom();
      case _:
        'true'.atom();
    }
  }

  public static function exit(process: Process): Atom {
    Reflect.setField(process, 'state', ProcessState.KILLED);
    return 'ok'.atom();
  }

  public static function running(process: Process): Atom {
    Reflect.setField(process, 'state', ProcessState.RUNNING);
    return 'ok'.atom();
  }

  public static function complete(process: Process): Atom {
    Reflect.setField(process, 'state', ProcessState.COMPLETE);
    return 'ok'.atom();
  }

  public static function waiting(process: Process): Atom {
    Reflect.setField(process, 'state', ProcessState.WAITING);
    return 'ok'.atom();
  }

  public static function receive(process: Process, callback: Function): Atom {
    Scheduler.receive(process, callback);
    return 'ok'.atom();
  }

  public static function self(): Process {
    var process: Process = Scheduler.threadProcessMap.get(Thread.current().handle);
    return process;
  }

  public static function sleep(milliseconds: Int): Atom {
    var process: Process = self();
    Reflect.setField(process, 'state', ProcessState.SLEEPING);
    Scheduler.sleep(process, milliseconds);
    return 'ok'.atom();
  }

  public static function apply(process: Process, ops: Array<Operation>): Void {
    var processStack = process.processStack;
    processStack.add(new AnnaCallStack(ops, processStack.getVariablesInScope()));
  }
}