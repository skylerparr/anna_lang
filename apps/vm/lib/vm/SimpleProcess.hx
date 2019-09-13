package vm;
using lang.AtomSupport;

class SimpleProcess implements Pid {
  public var server_id(default, never): Int;
  public var instance_id(default, never): Int;
  public var group_id(default, never): Int;
  public var processStack(default, never): DefaultProcessStack;
  public var state(default, never): ProcessState;
  public var mailbox(default, never): Array<Dynamic>;

  public inline function new(server_id: Int, instance_id: Int, group_id: Int, op: Operation) {
    var processStack: DefaultProcessStack = new DefaultProcessStack(this);
    processStack.add(new DefaultAnnaCallStack([op], new Map<String, Dynamic>()));

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



}