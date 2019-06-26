package tests;

import lang.UnableToMatchException;
import anna_unit.Assert;
import lang.EitherSupport;
import lang.AtomSupport;
using lang.AtomSupport;

@:build(Macros.build())
class PatternMatchTest {

  public static function shouldThrowUnableToMatchExceptionIfUnableToMatchString(): Void {
    var str: String = "";
    Assert.throwsException(function(): Void {
      @match "yes" = str;
    },UnableToMatchException);
  }

  public static function shouldMatchStringConstant(): Void {
    var str: String = "yes";
    @match "yes" = str;
  }

  public static function shouldMatchStringToVariable(): Void {
    var str: String = "yes";
    @match variable = str;
    @assert variable == str;
  }

  public static function shouldThrowMatchExceptionIfUnableToMatchInteger(): Void {
    var i: Int = 23;
    Assert.throwsException(function(): Void {
      @match 2 = i;
    },UnableToMatchException);
  }

  public static function shouldMatchIntegerConstant(): Void {
    var i: Int = 23;
    @match 23 = i;
  }

  public static function shouldMatchIntegerAndAssignToVariable(): Void {
    var i: Int = 23;
    @match variable = i;
    @assert variable == i;
  }

  public static function shouldThrowMatchExceptionIfUnableToMatchFloat(): Void {
    var i: Float = 23.23;
    Assert.throwsException(function(): Void {
      @match 2 = i;
    },UnableToMatchException);
  }

  public static function shouldMatchFloatConstant(): Void {
    var i: Float = 23.23;
    @match 23.23 = i;
  }

  public static function shouldMatchFloatAndAssignToVariable(): Void {
    var i: Float = 23;
    @match variable = i;
    @assert variable == i;
  }

  public static function shouldThrowMatchExceptionIfUnableToMatchAtom(): Void {
    var a: Atom = @atom 'foo';
    Assert.throwsException(function(): Void {
      @match @atom 'bar' = a;
    },UnableToMatchException);
  }

  public static function shouldMatchAtomConstant(): Void {
    var a: Atom = @atom 'foo';
    @match @atom 'foo' = a;

    @match @atom 'foo' = @atom 'foo';
  }

  public static function shouldMatchAtomAndAssignToVariable(): Void {
    var a: Atom = @atom 'foo';
    @match variable = a;
    @assert variable == a;
  }

  public static function shouldThrowMatchExceptionIfUnableToMatchTuple(): Void {
    var t: Tuple = @tuple[];
    Assert.throwsException(function(): Void {
      @match @tuple[1, 2] = t;
    },UnableToMatchException);
  }

  public static function shouldMatchTuple(): Void {
    var t: Tuple = @tuple[1, "2", @atom 'three'];
    @match @tuple[1, "2", @atom 'three'] = t;
  }

}