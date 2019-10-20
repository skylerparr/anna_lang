package ;

import haxe.Timer;
import lang.macros.MacroTools;
import vm.AnnaCallStack;
import anna_unit.Assert;
import vm.Function;
import mockatoo.Mockatoo;
import vm.ProcessStack;
import vm.Operation;
import core.ObjectCreator;
import vm.ProcessState;
import vm.DefaultProcessStack;
import vm.Pid;
import vm.schedulers.GenericScheduler;
import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;
@:build(lang.macros.Macros.build())
class GenericSchedulerTest {
  private static var scheduler: GenericScheduler;
  private static var objectCreator: ObjectCreator;

  private static var createdPid: Pid;

  public static function setup(): Void {
    scheduler = new GenericScheduler();
    objectCreator = mock(ObjectCreator);
    scheduler.objectCreator = objectCreator;

    createdPid = createPid();
  }

  private static function createPid(): Pid {
    var pid = mock(Pid);
    pid.state.returns(ProcessState.RUNNING);
    pid.mailbox.returns([]);
    return pid;
  }

  private static function mockFunction(): Function {
    var fn: Function = mock(Function);
    fn.scope.returns(new Map<String, Dynamic>());
    return fn;
  }

  public static function shouldReturnOkWhenStartingScheduler(): Void {
    @assert scheduler.start() == @_"ok";
  }

  public static function shouldReturnAlreadyStartedIfSchedulerIsAlreadyRunning(): Void {
    @assert scheduler.start() == @_"ok";
    @assert scheduler.start() == @_"already_started";
  }

  public static function shouldReturnOkWhenStoppingVM(): Void {
    @assert scheduler.start() == @_"ok";
    @assert scheduler.start() == @_"already_started";
    @assert scheduler.stop() == @_"ok";
    @assert scheduler.start() == @_"ok";
  }

  public static function nothingShouldHappenIfUpdateIsCalledBeforeTheSchedulerIsStarted(): Void {
    scheduler.update();
  }

  public static function shouldSpawnProcess(): Void {
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    scheduler.start();
    var pid = scheduler.spawn(function() { return operation; });

    @refute pid == null;
    @assert pid == scheduler.pids.first();
    Assert.areSameInstance(pid, createdPid);
    createdPid.start(operation).verify();
  }

  public static function shouldNotSpawnProcessIfSchedulerIsNotRunning(): Void {
    objectCreator.createInstance(cast any, cast any).returns(createdPid);
    var pid = scheduler.spawn(function() { return null; });
    @assert pid == null;
    objectCreator.createInstance(cast any, cast any).verify(never);
  }

  public static function shouldAssignParentPidWhenSpawningLink(): Void {
    var parentPid: Pid = mock(Pid);
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    scheduler.start();
    var pid = scheduler.spawnLink(parentPid, function() { return operation; });

    @refute pid == null;
    @assert pid == scheduler.pids.first();
    @assert pid == createdPid;
    createdPid.setParent(parentPid).verify();
  }

  public static function shouldReturnNullIfSchedulerIsNotRunningWhenSpawningLink(): Void {
    var parentPid: Pid = mock(Pid);
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    var pid = scheduler.spawnLink(parentPid, function() { return operation; });

    @assert pid == null;
    createdPid.setParent(parentPid).verify(never);
  }

  public static function shouldSetPidToComplete(): Void {
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    scheduler.start();
    var pid = scheduler.spawnLink(createdPid, function() { return operation; });
    scheduler.complete(pid);
    createdPid.setState(ProcessState.COMPLETE).verify();
  }

  #if !cppia
  public static function shouldDisposePidOnComplete(): Void {
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    scheduler.start();
    var pid = scheduler.spawnLink(createdPid, function() { return operation; });
    scheduler.complete(pid);

    createdPid.dispose().verify();
    @assert scheduler.pids.length() == 0;
  }
  #end

  public static function shouldDoNothingIfCompleteIsCalledAndSchedulerIsNotRunning(): Void {
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    var pid = scheduler.spawnLink(createdPid, function() { return operation; });
    scheduler.complete(pid);

    createdPid.dispose().verify(0);
  }

  public static function shouldSetPidToKilled(): Void {
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    scheduler.start();
    var pid = scheduler.spawnLink(createdPid, function() { return operation; });
    scheduler.exit(pid, @_'kill');
    createdPid.setState(ProcessState.KILLED).verify();
  }

  #if !cppia
  public static function shouldDisposePidOnExit(): Void {
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    scheduler.start();
    var pid = scheduler.spawnLink(createdPid, function() { return operation; });
    scheduler.exit(pid, @_'kill');

    createdPid.dispose().verify();
    @assert scheduler.pids.length() == 0;
  }
  #end

  public static function shouldDoNothingIfExitIsCalledAndSchedulerIsNotRunning(): Void {
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    var pid = scheduler.spawnLink(createdPid, function() { return operation; });
    scheduler.exit(pid, @_'kill');

    createdPid.dispose().verify(0);
  }

  public static function shouldInvokeTheOperationExecuteWhenCallingUpdateOnALoadedScheduler(): Void {
    var operation: Operation = mock(Operation);
    var processStack: ProcessStack = mock(ProcessStack);
    createdPid.processStack.returns(processStack);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);
    createdPid.state.returns(ProcessState.RUNNING);

    scheduler.start();
    var pid = scheduler.spawn(function() { return operation; });
    scheduler.update();
    processStack.execute().verify();
  }

  public static function shouldInvokeTheOperationExecuteMoreThanOnceWhenCallingUpdateMoreThanOnce(): Void {
    var operation: Operation = mock(Operation);
    var processStack: ProcessStack = mock(ProcessStack);
    createdPid.processStack.returns(processStack);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);
    createdPid.state.returns(ProcessState.RUNNING);

    scheduler.start();
    var pid = scheduler.spawn(function() { return operation; });
    for(i in 0...4) {
      scheduler.update();
    }
    processStack.execute().verify(4);
  }

  public static function shouldRoundRobinBetweenProcessWhenCallingUpdate(): Void {
    var createdPid2: Pid = mock(Pid);
    createdPid2.mailbox.returns([]);
    var operation: Operation = mock(Operation);
    var processStack: ProcessStack = mock(ProcessStack);
    var processStack2: ProcessStack = mock(ProcessStack);
    createdPid.processStack.returns(processStack);
    createdPid2.processStack.returns(processStack2);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);
    objectCreator.createInstance(cast any, cast any).returns(createdPid2);
    createdPid.state.returns(ProcessState.RUNNING);
    createdPid2.state.returns(ProcessState.RUNNING);

    scheduler.start();
    var pid1 = scheduler.spawn(function() { return operation; });
    var pid2 = scheduler.spawn(function() { return operation; });
    @refute pid1 == null;
    @refute pid2 == null;
    @refute pid1 == pid2;
    for(i in 0...5) {
      scheduler.update();
    }
    processStack.execute().verify(3);
    processStack2.execute().verify(2);
  }

  public static function shouldRemoveProcessFromProcessListIfStatusIsNotRunning(): Void {
    var operation: Operation = mock(Operation);
    var processStack: ProcessStack = mock(ProcessStack);
    createdPid.processStack.returns(processStack);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    createdPid.state.returns(ProcessState.RUNNING);
    var counter: Int = 0;
    processStack.execute().calls(function() {
      counter++;
      if((counter >= 2)) {
        createdPid.state.returns(ProcessState.COMPLETE);
      }
    });

    scheduler.start();
    var pid = scheduler.spawn(function() { return operation; });
    for(i in 0...40) {
      scheduler.update();
    }
    processStack.execute().verify(2);
  }

  public static function shouldReturnNullPidWhenSpawningIfSchedulerIsNotRunning(): Void {
    var operation: Operation = mock(Operation);
    var processStack: ProcessStack = mock(ProcessStack);
    createdPid.processStack.returns(processStack);
    objectCreator.createInstance(cast any).returns(createdPid);
    var pid = scheduler.spawn(function() { return operation; });
    @assert pid == null;
  }

  public static function shouldUpdateAPidsMailboxWhenSendingAMessage(): Void {
    scheduler.start();
    @assert @_"ok" == scheduler.send(createdPid, "foo");
    createdPid.putInMailbox("foo").verify();
  }

  public static function shouldReturnAtomMessageThatSchedulerIsNotRunningWhenAttemptingToSendAMessage(): Void {
    @assert @_"not_running" == scheduler.send(createdPid, "foo");
  }

  public static function shouldNotChangePidStateWhenSendingAMessageToIt(): Void {
    createdPid.state.returns(ProcessState.RUNNING);
    scheduler.start();
    @assert @_"ok" == scheduler.send(createdPid, "foo");
    createdPid.setState(cast any).verify(never);
  }

  public static function shoudNotChangeStateIfStateIsRunningIfSendingMessage(): Void {
    createdPid.state.returns(ProcessState.SLEEPING);
    scheduler.start();
    @assert @_"ok" == scheduler.send(createdPid, "foo");
    createdPid.setState(ProcessState.RUNNING).verify(never);
  }

  public static function shouldSetProcessToWaitingWhenPutIntoReceiveMode(): Void {
    createdPid.state.returns(ProcessState.RUNNING);
    scheduler.start();
    var fn: Function = mockFunction();
    scheduler.receive(createdPid, fn, 500);
    createdPid.setState(ProcessState.WAITING).verify();
    @assert scheduler.sleepingProcesses.length() == 1;
  }

  public static function shouldDoNothingIfPutIntoReceiveModeAndTheSchedulerIsntRunning(): Void {
    createdPid.state.returns(ProcessState.RUNNING);
    var fn: Function = mockFunction();
    scheduler.receive(createdPid, fn);
    createdPid.setState(ProcessState.WAITING).verify(never);
  }

  public static function shouldNotChangeStateIfReceiveIsCallOnProcessThatIsInAnyOtherStateOtherThanRUNNING(): Void {
    createdPid.state.returns(ProcessState.SLEEPING);
    scheduler.start();
    var fn: Function = mockFunction();
    scheduler.receive(createdPid, fn);
    createdPid.setState(ProcessState.WAITING).verify(never);
  }

  public static function shouldPutPidIntoWaitingIfTimeoutIsNull(): Void {
    createdPid.state.returns(ProcessState.RUNNING);
    scheduler.start();
    var fn: Function = mockFunction();
    scheduler.receive(createdPid, fn);
    createdPid.setState(ProcessState.WAITING).verify();
    @assert scheduler.sleepingProcesses.length() == 0;
  }

  public static function shouldAddPidToSleepingProcesses(): Void {
    createdPid.state.returns(ProcessState.RUNNING);
    scheduler.start();
    var callback = function(v) {};
    var fn: Function = mockFunction();
    scheduler.receive(createdPid, fn, 300, callback);
    var pidMeta = scheduler.sleepingProcesses.first();
    @refute pidMeta == null;
    Assert.areSameInstance(pidMeta.pid, createdPid);
    @assert pidMeta.timeout == 300;
    Assert.areSameInstance(pidMeta.callback, callback);
    Assert.areSameInstance(pidMeta.fn, fn);
  }

  public static function shouldAddAnInvokeCallbackOperationToTheCurrentPidProcessStackWhenApplyingFunction(): Void {
    var func: Function = mockFunction();
    var operations: Array<Operation> = [mock(Operation)];
    var allOperations: Array<Operation> = null;
    var processStack: ProcessStack = mock(ProcessStack);
    processStack.add(cast any).calls(function(arg: Array<AnnaCallStack>): Void {
      allOperations = arg[0].operations;
    });

    createdPid.processStack.returns(processStack);
    func.invoke(cast any).returns(operations);

    scheduler.start();
    scheduler.pids.push(createdPid);
    scheduler.apply(createdPid, func, [], new Map<String, Dynamic>(), function(r) {});

    func.invoke(cast any).verify();
    processStack.add(cast any).verify();

    @assert allOperations.length == 1;
  }

  public static function shouldNotAddAnInvokeCallbackOperationToTheCurrentPidProcessStackWhenApplyingFunctionWhenCallbackIsNull(): Void {
    var func: Function = mockFunction();
    var operations: Array<Operation> = [mock(Operation)];
    var allOperations: Array<Operation> = null;
    var processStack: ProcessStack = mock(ProcessStack);
    processStack.add(cast any).calls(function(arg: Array<AnnaCallStack>): Void {
      allOperations = arg[0].operations;
    });

    createdPid.processStack.returns(processStack);
    func.invoke(cast any).returns(operations);

    scheduler.start();
    scheduler.apply(createdPid, func, [], new Map<String, Dynamic>(), null);

    func.invoke(cast any).verify();
    processStack.add(cast any).verify();

    @assert allOperations.length == 1;
  }

  public static function shouldPassArgsAndScopeVariablesToFunctionInvokeOnApply(): Void {
    var func: Function = mockFunction();
    var operations: Array<Operation> = [mock(Operation)];
    var allOperations: Array<Operation> = null;
    var processStack: ProcessStack = mock(ProcessStack);
    processStack.add(cast any).calls(function(arg: Array<AnnaCallStack>): Void {
      allOperations = arg[0].operations;
    });

    var scope = new Map<String, Dynamic>();
    createdPid.processStack.returns(processStack);
    func.invoke(cast any).calls(function(args: Array<Dynamic>): Array<Operation> {
      switch(args[0]) {
        case [one, two, three, four, five]:
          @assert one == 1;
          @assert two == 2.3;
          @assert three == "3";
          @assert four == @_"four";
          Assert.areSameInstance(five, scope);
        case _:
          Assert.fail('Incorrect number of passed args. Expected 5 got ${args.length}');
      }
      return operations;
    });

    scheduler.start();
    scheduler.apply(createdPid, func, [1, 2.3, "3", @_"four"], scope, null);
    func.invoke(cast any).verify();
  }

  public static function shouldDoNothingIfCallingApplyAndSchedulerIsntRunning(): Void {
    var func: Function = mockFunction();
    var operations: Array<Operation> = [mock(Operation)];
    var allOperations: Array<Operation> = null;
    var processStack: ProcessStack = mock(ProcessStack);
    processStack.add(cast any).calls(function(arg: Array<AnnaCallStack>): Void {
      allOperations = arg[0].operations;
    });

    createdPid.processStack.returns(processStack);
    func.invoke(cast any).returns(operations);

    scheduler.apply(createdPid, func, [], new Map<String, Dynamic>(), function(r) {});

    func.invoke(cast any).verify(never);
    processStack.add(cast any).verify(never);

    @assert allOperations == null;
  }

  public static function shouldSetPidStateToKilledIfToldToExit(): Void {
    var pid: Pid = mock(Pid);
    scheduler.start();
    @assert @_"killed" = scheduler.exit(pid, @_"normal");
    pid.setState(ProcessState.KILLED).verify();
    @assert scheduler.pids.length() == 0;
    @assert scheduler.pidMetaMap.exists(pid) == false;
  }

  public static function shouldReturnSelf(): Void {
    var operation: Operation = mock(Operation);
    var processStack: ProcessStack = mock(ProcessStack);
    createdPid.processStack.returns(processStack);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);
    createdPid.state.returns(ProcessState.RUNNING);

    scheduler.start();
    var pid = scheduler.spawn(function() { return operation; });
    scheduler.update();

    Assert.areSameInstance(scheduler.self(), createdPid, MacroTools.line() + "");
  }

  public static function shouldPutPidToSleep(): Void {
    createdPid.state.returns(ProcessState.RUNNING);
    scheduler.start();
    Assert.areSameInstance(scheduler.sleep(createdPid, 300), createdPid);
    createdPid.setState(ProcessState.SLEEPING).verify();
    @assert scheduler.sleepingProcesses.length() == 1;
    Assert.areSameInstance(scheduler.sleepingProcesses.pop().pid, createdPid);
  }

  public static function shouldDoNothingWhenPidIsToldToSleepIfSchedulerIsNotRunning(): Void {
    createdPid.state.returns(ProcessState.RUNNING);
    Assert.areSameInstance(scheduler.sleep(createdPid, 300), createdPid);
    createdPid.setState(ProcessState.SLEEPING).verify(never);
  }

  public static function pidsShouldBeExecutedAfterSleepCompletes(): Void {
    var operation: Operation = mock(Operation);
    var processStack: ProcessStack = mock(ProcessStack);
    processStack.execute().calls(function(args): Void {
      createdPid.state.returns(ProcessState.COMPLETE);
    });
    createdPid.processStack.returns(processStack);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);
    createdPid.setState(ProcessState.WAITING).calls(function(args) {
      createdPid.state.returns(ProcessState.WAITING);
    });
    createdPid.setState(ProcessState.RUNNING).calls(function(args) {
      createdPid.state.returns(ProcessState.RUNNING);
    });

    var timeout: Float = 1; // timeout after 1 second
    var now: Float = Timer.stamp();

    scheduler.start();
    var pid = scheduler.spawn(function() {
      return operation;
    });
    scheduler.sleep(pid, 2);
    while(true) {
      scheduler.update();
      if(Timer.stamp() - now > timeout) {
        Assert.fail("Test timed out");
        break;
      }
      if(scheduler.pids.length() == 0 && scheduler.sleepingProcesses.length() == 0) {
        break;
      }
    }
    Assert.success();
    createdPid.setState(ProcessState.SLEEPING).verify();
    createdPid.setState(ProcessState.RUNNING).verify();
  }

  public static function shouldBeAbleToSendMessageToProcessAndHaveTheProcessReadIt(): Void {
    var mailbox: Array<Dynamic> = [];
    createdPid.mailbox.returns(mailbox);
    createdPid.state.returns(ProcessState.RUNNING);
    createdPid.setState(ProcessState.WAITING).calls(function(a): Void {
      createdPid.state.returns(ProcessState.WAITING);
    });
    createdPid.setState(ProcessState.RUNNING).calls(function(a): Void {
      createdPid.state.returns(ProcessState.RUNNING);
    });
    var processStack: ProcessStack = mock(ProcessStack);
    var scope = new Map<String, Dynamic>();
    processStack.getVariablesInScope().returns(scope);
    var annaStack: AnnaCallStack = null;
    processStack.add(cast any).calls(function(args): Void {
      annaStack = args[0];
      @assert annaStack.scopeVariables.get("$$$") == "hello world";
    });
    processStack.execute().calls(function(): Void {
      scope.set("$$$", scope.get("value_data"));
      if(annaStack != null) {
        annaStack.execute(processStack);
      }
    });
    createdPid.putInMailbox(cast any).calls(function(args) {
      mailbox.push(args[0]);
    });
    createdPid.processStack.returns(processStack);

    scheduler.start();
    scheduler.pids.push(createdPid);
    var cbCalled: Bool = false;
    var fn: Function = mockFunction();
    // LOOK HERE... LOOK! LOOK! AN IMPORT NOTE HERE
    // IF YOU DON'T PASS AT LEAST 1 OPERATION, THIS TEST
    // WILL SEGFAULT.
    var op: Operation = mock(Operation);
    op.execute(cast any, cast any).calls(function(args: Array<Dynamic>): Void {
      var scope: Map<String, Dynamic> = args[0];
      @assert scope.get("value_data") == "hello world";
      @assert scope.get("$$$") == "hello world";
    });
    fn.invoke(cast any).returns([op]);
    fn.args.returns(["value_data"]);
    var i: Int = 0;
    while(i < 20) {
      scheduler.update();
      i++;
    }
    scheduler.receive(createdPid, fn, null, function(message): Void {
      cbCalled = true;
      @assert message == "hello world";
    });
    var i: Int = 0;
    while(i < 20) {
      scheduler.update();
      i++;
    }
    scheduler.send(createdPid, "hello world");

    var i: Int = 0;
    while(i < 20) {
      scheduler.update();
      i++;
    }
    Assert.isTrue(cbCalled);
    op.execute(cast any, cast any).verify();
  }

  public static function shouldBeAbleToSendMessageToProcessBeforeItsReadyToReceiveAndShouldHandleItWhenPutIntoReceiveState(): Void {
    var mailbox: Array<Dynamic> = [];
    createdPid.mailbox.returns(mailbox);
    createdPid.state.returns(ProcessState.RUNNING);
    createdPid.setState(ProcessState.WAITING).calls(function(a): Void {
      createdPid.state.returns(ProcessState.WAITING);
    });
    createdPid.setState(ProcessState.RUNNING).calls(function(a): Void {
      createdPid.state.returns(ProcessState.RUNNING);
    });
    var processStack: ProcessStack = mock(ProcessStack);
    var scope = new Map<String, Dynamic>();
    processStack.getVariablesInScope().returns(scope);
    var annaStack: AnnaCallStack = null;
    processStack.add(cast any).calls(function(args): Void {
      annaStack = args[0];
      @assert annaStack.scopeVariables.get("$$$") == "hello world";
    });
    processStack.execute().calls(function(): Void {
      scope.set("$$$", scope.get("value_data"));
      if(annaStack != null) {
        annaStack.execute(processStack);
      }
    });
    createdPid.putInMailbox(cast any).calls(function(args) {
      mailbox.push(args[0]);
    });
    createdPid.processStack.returns(processStack);

    scheduler.start();
    scheduler.pids.push(createdPid);
    scheduler.send(createdPid, "hello world");
    var cbCalled: Bool = false;
    var fn: Function = mockFunction();
    // LOOK HERE... LOOK! LOOK! AN IMPORT NOTE HERE
    // IF YOU DON'T PASS AT LEAST 1 OPERATION, THIS TEST
    // WILL SEGFAULT.
    var op: Operation = mock(Operation);
    op.execute(cast any, cast any).calls(function(args: Array<Dynamic>): Void {
      var scope: Map<String, Dynamic> = args[0];
      @assert scope.get("value_data") == "hello world";
      @assert scope.get("$$$") == "hello world";
    });
    fn.invoke(cast any).returns([op]);
    fn.args.returns(["value_data"]);
    scheduler.receive(createdPid, fn, null, function(message): Void {
      cbCalled = true;
      @assert message == "hello world";
    });

    var i: Int = 0;
    while(i < 20) {
      scheduler.update();
      i++;
    }
    Assert.isTrue(cbCalled);
    op.execute(cast any, cast any).verify();
  }

  public static function shouldReturnFalseIfSchedulerHasNothingToDo(): Void {
    scheduler.start();
    Assert.isFalse(scheduler.hasSomethingToExecute());
  }

  public static function shouldReturnTrueIfSchedulerHasSomethingToDo(): Void {
    scheduler.start();
    var operation: Operation = mock(Operation);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);

    scheduler.start();
    scheduler.spawn(function() { return operation; });
    Assert.isTrue(scheduler.hasSomethingToExecute());
  }

  public static function shouldCheckOnSleepingProcessWhenCheckingToSeeIfSchedulerHasSomethingToDo(): Void {
    var operation: Operation = mock(Operation);
    var processStack: ProcessStack = mock(ProcessStack);
    processStack.execute().calls(function(args): Void {
      createdPid.state.returns(ProcessState.COMPLETE);
    });
    createdPid.processStack.returns(processStack);
    objectCreator.createInstance(cast any, cast any).returns(createdPid);
    createdPid.setState(ProcessState.WAITING).calls(function(args) {
      createdPid.state.returns(ProcessState.WAITING);
    });
    createdPid.setState(ProcessState.RUNNING).calls(function(args) {
      createdPid.state.returns(ProcessState.RUNNING);
    });

    var timeout: Float = 1; // timeout after 1 second
    var now: Float = Timer.stamp();

    scheduler.start();
    var pid = scheduler.spawn(function() {
      return operation;
    });
    scheduler.sleep(pid, 2);
    while(true) {
      if(scheduler.hasSomethingToExecute()) {
        scheduler.update();
      }
      if(Timer.stamp() - now > timeout) {
        Assert.fail("Test timed out");
        break;
      }
      if(scheduler.pids.length() == 0 && scheduler.sleepingProcesses.length() == 0) {
        break;
      }
    }
  }

  public static function shouldExitParentPidIfLinked(): Void {
    var parentPid: Pid = createPid();
    createdPid.parent.returns(parentPid);
    scheduler.start();
    scheduler.exit(createdPid, @_'kill');
    parentPid.setState(ProcessState.KILLED).verify();
  }

  public static function shouldNotExitProcessIfTrapExitIsSetToTrue(): Void {
    createdPid.setTrapExit(Atom.create('true')).calls(function(args): Void {
      createdPid.trapExit.returns(Atom.create('true'));
    });
    scheduler.start();
    scheduler.flag(createdPid, Atom.create('trap_exit'), Atom.create('true'));
    scheduler.exit(createdPid, @_'kill');

    createdPid.setState(ProcessState.KILLED).verify(never);
  }
}