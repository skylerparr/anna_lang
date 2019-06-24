package tests;

import lang.UnableToMatchException;
import anna_unit.Assert;
import lang.EitherSupport;
import lang.AtomSupport;
using lang.AtomSupport;

@:build(Macros.build())
class PatternMatchTest {

//  public static function shouldUnableToMatchExceptionIfUnableToMatchString(): Void {
//    var str: String = "yes";
//    Assert.throwsException(function(): Void {
//      @match "yes" = str;
//    },UnableToMatchException);
//  }
//  
  public static function shouldMatchStringConstant(): Void {
    var str: String = "yes";
    @match "yes" = str;
  }
}