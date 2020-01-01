package ;
import anna_unit.Assert;
import Tuple;
import lang.Lang;
@:build(lang.macros.Macros.build())
class LangTest {
  public static function shouldConvertVariableToAS(): Void {
    var ast: Tuple = Lang.stringToAst('foo');
    Assert.areEqual(ast, @tuple[@_'ok', @tuple[@tuple[@_'var', 'foo'], @_'Dynamic', 0]]);
  }

  public static function shouldConvertStringToAstTuple(): Void {
    var ast: Tuple = Lang.stringToAst('"foo"');
    Assert.areEqual(ast, @tuple[@_'ok', @tuple[@tuple[@_'const', 'foo'], @_'String', 0]]);
  }

  public static function shouldConvertIntegerToAstTuple(): Void {
    var ast: Tuple = Lang.stringToAst('839');
    Assert.areEqual(ast, @tuple[@_'ok', @tuple[@tuple[@_'const', 839], @_'Number', 0]]);
  }

  public static function shouldConvertFloatToAstTuple(): Void {
    var ast: Tuple = Lang.stringToAst('839.293');
    Assert.areEqual(ast, @tuple[@_'ok', @tuple[@tuple[@_'const', 839.293], @_'Number', 0]]);
  }

  public static function shouldConvertAtomToAstTuple(): Void {
    var ast: Tuple = Lang.stringToAst('@_"foo"');
    Assert.areEqual(ast, @tuple[@_'ok', @tuple[@tuple[@_'const', @_'foo'], @_'Atom', 0]]);
  }

  public static function shouldConvertTupleToAstTuple(): Void {
    var ast: Tuple = Lang.stringToAst('[@_"ok", "foo"]');
    Assert.areEqual(ast.toAnnaString(), '[:ok, [[:const, [[[:const, :ok], Atom, 0], [[:const, "foo"], String, 0]]], Tuple, 0]]');
  }

  public static function shouldConvertLListToAstTuple(): Void {
    var ast: Tuple = Lang.stringToAst('{@_"ok"; "foo";}');
    Assert.areEqual(ast.toAnnaString(), '[:ok, [[:const, [[[:const, :ok], Atom, 0], [[:const, "foo"], String, 0]]], LList, 0]]');
  }

  public static function shouldConvertKeywordToAstTuple(): Void {
    var ast: Tuple = Lang.stringToAst('{foo: "bar", baz: 321}');
    Assert.areEqual(ast.toAnnaString(), '[:ok, [[:const, [[[[:const, :foo], Atom, 0], [[:const, "bar"], String, 0]], [[[:const, :baz], Atom, 0], [[:const, 321], Number, 0]]]], Keyword, 0]]');
  }

  public static function shouldConvertMapToAstTuple(): Void {
    var ast: Tuple = Lang.stringToAst('["foo" => "bar", "baz" => 321]');
    Assert.areEqual(ast.toAnnaString(), '[:ok, [[:const, [[[[:const, "foo"], String, 0], [[:const, "bar"], String, 0]], [[[:const, "baz"], String, 0], [[:const, 321], Number, 0]]]], MMap, 0]]');

    var ast: Tuple = Lang.stringToAst('[@_"foo" => "bar", "baz" => 321]');
    Assert.areEqual(ast.toAnnaString(), '[:ok, [[:const, [[[[:const, :foo], Atom, 0], [[:const, "bar"], String, 0]], [[[:const, "baz"], String, 0], [[:const, 321], Number, 0]]]], MMap, 0]]');

    var ast: Tuple = Lang.stringToAst('[1 => "bar", [@_"ok", "TupleKey"] => 321]');
    Assert.areEqual(ast.toAnnaString(), '[:ok, [[:const, [[[[:const, "foo"], String, 0], [[:const, "bar"], String, 0]], [[[:const, "baz"], String, 0], [[:const, 321], Number, 0]]]], MMap, 0]]');
  }
}
