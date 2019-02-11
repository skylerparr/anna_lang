package anna_unit;

import lang.StandardException;
import anna_unit.TestFailureException;
@:build(macros.ScriptMacros.script())
class Assert {

  private static function structuresAreEqual(args: Array<Dynamic>): Bool {
    return (args[0] + "") == (args[1] + "");
  }

  private static function areSameDataTypesEqual(args: Array<Dynamic>): Bool {
    var a: Dynamic = args[0];
    var b: Dynamic = args[1];
    return Type.typeof(a) == Type.typeof(b);
  }

  public static function fail(errString: String): Void {
    throw new TestFailureException(errString);
  }

  public static function areEqual(a: Dynamic, b: Dynamic): Void {
    var values = [a, b];
    switch(values) {
      case areSameDataTypesEqual(_) => true:
      case structuresAreEqual(_) => true:
      case _:
        var errString = '';
        errString += '\n';
        errString += 'are not equal, expected to be equal\n';
        errString += '\n';
        errString += 'lhs: ${a}\n';
        errString += 'rhs: ${b}\n';
        fail(errString);
    }
  }

  public static function areNotEqual(a: Dynamic, b: Dynamic): Void {
    var values = [a, b];
    switch(values) {
      case areSameDataTypesEqual(_) => false:
      case structuresAreEqual(_) => false:
      case _:
        var errString = '';
        errString += '\n';
        errString += 'are equal, expected to not be equal\n';
        errString += '\n';
        errString += 'lhs: ${a}\n';
        errString += 'rhs: ${b}\n';
        fail(errString);
    }
  }

  public static function throwsException(func: Void -> Void, ex: Class<StandardException>): Void {
    try {
      func();
      var errString = '';
      errString += 'Expected ${ex} to be thrown, was not thrown.\n';
      fail(errString);
    } catch(e: Dynamic) {
      if(!Std.is(e, ex)) {
        var errString = '';
        errString += 'Expected ${ex} to be thrown, ${e} was thrown.\n';
        fail(errString);
      }
    }
  }
}