package tests;

import lang.EitherSupport;
import lang.AtomSupport;
using lang.AtomSupport;

@:build(Macros.build())
class PatternMatchTest {
  public static function shouldMatchStringConstant(): Void {
    var str: String = "yes";
    var retVal:MMap = @map [];
    @match "yes" = str;
  }
}