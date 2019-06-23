package tests;

@:build(Macros.build())
class AssertMacroTest {
  public static function shouldAssertEquality(): Void {
    var a: String = '';
    var b: String = '';
    @assert a == b;
  }
}