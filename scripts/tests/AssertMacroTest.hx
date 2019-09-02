package tests;

@:build(lang.macros.Macros.build())
class AssertMacroTest {
  public static function shouldAssertEquality(): Void {
    var a: String = '';
    var b: String = '';
    @assert a == b;
  }

  public static function shouldRefuteEquality(): Void {
    var a: String = 'a';
    var b: String = 'b';
    @refute a == b;
  }
}