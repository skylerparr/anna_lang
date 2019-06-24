package tests;

import lang.UnableToMatchException;
import anna_unit.Assert;
import lang.EitherSupport;
import lang.AtomSupport;
using lang.AtomSupport;

@:build(Macros.build())
class PatternMatchTest {

  public static function shouldUnableToMatchExceptionIfUnableToMatchString(): Void {
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
}