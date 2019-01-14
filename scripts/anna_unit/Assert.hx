package anna_unit;

import deepequal.DeepEqual;
import anna_unit.TestFailureException;
@:build(macros.ScriptMacros.script())
class Assert {

  public static function areEqual(a: Dynamic, b: Dynamic): Void {
    switch(DeepEqual.compare(a, b)) {
      case Success(_):
      case Failure(f):
        var errString = '';
        errString += '\n';
        errString += 'are not equal, expected to be equal\n';
        errString += '\n';
        errString += 'lhs: ${a}\n';
        errString += 'rhs: ${b}\n';
        throw new TestFailureException(errString);
    }
  }
}