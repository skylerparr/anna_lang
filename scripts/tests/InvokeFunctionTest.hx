package tests;

import lang.FunctionClauseNotFound;
import anna_unit.Assert;
import vm.InvokeFunction;
@:build(Macros.build())
class InvokeFunctionTest {
  private static var scope: Map<String, Dynamic>;

  public static function setup(): Void {
    scope = new Map<String, Dynamic>();
    Sample.reset();
  }

  public static function shouldCallFunctionWithNoArgs(): Void {
    var invoke: InvokeFunction = new InvokeFunction(Sample.noArgs, @list[]);
    invoke.execute(scope, null);
    Assert.areEqual(Sample.noArgsCalled, 1);
  }

  public static function shouldCallFunctionWithOneArg(): Void {
    var invoke: InvokeFunction = new InvokeFunction(Sample.oneArg, @list[@tuple[@atom'const', "foo"]]);
    invoke.execute(scope, null);
    Assert.areEqual(Sample.oneArgValue, "foo");
  }

  public static function shouldCallFunctionWithVariableArgs(): Void {
    scope.set("foo", "bar");
    var invoke: InvokeFunction = new InvokeFunction(Sample.oneArg, @list[@tuple[@atom'var', "foo"]]);
    invoke.execute(scope, null);
    Assert.areEqual(Sample.oneArgValue, "bar");
  }

  public static function shouldCallFunctionWithVariableArgsOfMultipleTypes(): Void {
    var invoke: InvokeFunction = new InvokeFunction(Sample.twoArgs, @list[@tuple[@atom'const', @tuple['a', 'b', 'c']], @tuple[@atom'const', @map['a' => 2, 'b' => 3]]]);
    invoke.execute(scope, null);
    Assert.areEqual(Sample.arg1, @tuple['a', 'b', 'c']);
    Assert.areEqual(Sample.arg2, @map['a' => 2, 'b' => 3]);
  }

  public static function shouldAssignReturnToSpecialVar(): Void {
    var invoke: InvokeFunction = new InvokeFunction(Sample.withReturn,
      @list[@tuple[@atom'const', @tuple['a', 'b', 'c']]]);
    invoke.execute(scope, null);
    Assert.areEqual(scope.get("$$$"), @tuple['a', 'b', 'c']);
  }

}

class Sample {
  public static var noArgsCalled: Int = 0;
  public static var oneArgValue: String;

  public static var arg1: Tuple;
  public static var arg2: MMap;

  public static function reset(): Void {
    noArgsCalled = 0;
  }

  public static function noArgs(): Void {
    noArgsCalled++;
  }

  public static function oneArg(arg: String): Void {
    oneArgValue = arg;
  }

  public static function twoArgs(t: Tuple, m: MMap): Void {
    arg1 = t;
    arg2 = m;
  }

  public static function withReturn(t: Tuple): Tuple {
    return t;
  }
}