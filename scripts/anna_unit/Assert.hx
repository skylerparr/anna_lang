package anna_unit;

import Type;
import lang.CustomTypes;
import lang.StandardException;
import anna_unit.TestFailureException;
@:build(macros.ScriptMacros.script())
class Assert {

  private static function structuresAreEqual(args: Array<Dynamic>): Bool {
    if(areCustomTypes(args)) {
      return args[0] == args[1];
    } else {
      return (Anna.inspect(args[0])) == (Anna.inspect(args[1]));
    }
  }

  private static function areSameDataTypesEqual(args: Array<Dynamic>): Bool {
    var a: Dynamic = args[0];
    var b: Dynamic = args[1];
    return Type.typeof(a) == Type.typeof(b) && a == b;
  }

  public static function areCustomTypes(args: Array<Dynamic>): Bool {
    var a: Dynamic = args[0];
    var b: Dynamic = args[1];

    return (Std.is(a, CustomType) || Std.is(b, CustomType));
  }

  public static function fail(errString: String): Void {
    throw new TestFailureException(errString);
  }

  public static function stringsAreEqual(a: String, b: String): Void {
    if(a != b) {
      var errString = '';
      errString += '\n';
      errString += 'are not equal, expected to be equal\n';
      errString += '\n';
      errString += 'lhs: ${a}\n';
      errString += 'rhs: ${b}\n';
      fail(errString);
    }
  }

  public static function areEqual(a: Dynamic, b: Dynamic): Void {
    var values = [a, b];
    if(!areSameDataTypesEqual(values) &&
      !structuresAreEqual(values)) {
      var errString = '';
      errString += '\n';
      errString += 'are not equal, expected to be equal\n';
      errString += '\n';
      errString += 'lhs: ${Anna.inspect(a)}\n';
      errString += 'rhs: ${Anna.inspect(b)}\n';
      fail(errString);
    }
  }

  public static function areNotEqual(a: Dynamic, b: Dynamic): Void {
    var values = [a, b];
    if(areSameDataTypesEqual(values) &&
      structuresAreEqual(values)) {
      var errString = '';
      errString += '\n';
      errString += 'are equal, expected to not be equal\n';
      errString += '\n';
      errString += 'lhs: ${Anna.inspect(a)}\n';
      errString += 'rhs: ${Anna.inspect(b)}\n';
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

  public static function isNull(value: Dynamic): Bool {
    return value == null;
  }
}