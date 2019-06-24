package tests;

import lang.EitherSupport;
import lang.AtomSupport;
using lang.AtomSupport;

@:build(Macros.build())
class PatternMatchTest {
  public static function shouldMatchStringConstant(): Void {
    var scope: Map<String, Dynamic> = new Map<String, Dynamic>();
    var str: String = "yes";
    @match"yes" == str;
  }
}