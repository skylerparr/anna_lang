package tests;

import lang.ParsingException;
import lang.LangParser;
import anna_unit.Assert;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class LangParserTest {

  public static function shouldConvertStringToAst(): Void {
    Assert.areEqual(LangParser.toAST('"foo"'), 'foo');
    Assert.areNotEqual(LangParser.toAST('"foo"'), 'foobert');
  }

  public static function shouldThrowParsingErrorIsStringIsNeverEndQuoted(): Void {
    Assert.throwsException(function(): Void { LangParser.toAST('"foo'); }, ParsingException);
  }

  public static function shouldEscapeStrings(): Void {
    Assert.areEqual(LangParser.toAST('"foo\\"s"'), 'foo"s');
  }

  public static function shouldThrowExceptionIfEndsInEscapeString(): Void {
    Assert.throwsException(function(): Void { LangParser.toAST('"foo\\'); }, ParsingException);
  }

  public static function shouldConvertNumberToAst(): Void {
    Assert.areEqual(LangParser.toAST("123"), 123);
    Assert.areEqual(LangParser.toAST("  123  "), 123);

    Assert.areNotEqual(LangParser.toAST('"123"'), 123);
    Assert.areNotEqual(LangParser.toAST('123'), '123');
  }

  public static function shouldConvertAtomToAst(): Void {
    Assert.areEqual(LangParser.toAST(":foo"), "foo".atom());
    Assert.areEqual(LangParser.toAST("  :foo   "), "foo".atom());

    Assert.areNotEqual(LangParser.toAST('":foo"'), "foo".atom());
  }

  public static function shouldConvertQuotedAtomWithDoubleQuoteToAst(): Void {
    Assert.areEqual(LangParser.toAST(':"foo\\"s"'), 'foo"s'.atom());
  }

  public static function shouldThrowExceptionOnQuotedAtomWithHangingEscape(): Void {
    Assert.throwsException(function() { LangParser.toAST(':"foo\\'); }, ParsingException);
  }

  public static function shouldConvertAtomInQuote(): Void {
    Assert.areEqual(LangParser.toAST(':"foo + 1"'), 'foo + 1'.atom());
  }

  public static function shouldThrowExceptionIfQuoteIsNeverTerminated(): Void {
    Assert.throwsException(function() { LangParser.toAST(':"foo + 1'); }, ParsingException);
  }

  public static function shouldConvertArrayToAst(): Void {
    Assert.areEqual(LangParser.toAST("{    }"), []);
    Assert.areNotEqual(LangParser.toAST('"{}"'), []);
  }

  public static function shouldConvertArrayWithValues(): Void {
    Assert.areEqual(LangParser.toAST('{  2,  :foo  , "house"  , 292  }'), [2, 'foo'.atom(), 'house', 292]);
  }

  public static function shouldConvertArrayWithValuesWithTrailingComma(): Void {
    Assert.areEqual(LangParser.toAST('{  2,  :foo  , "house"  , 292  ,  }'), [2, 'foo'.atom(), 'house', 292]);
  }

  public static function shouldConvertArrayWithNestedArrays(): Void {
    Assert.areEqual(LangParser.toAST('{{}}'), [[]]);
    Assert.areEqual(LangParser.toAST('{{}, {}, {}}'), [[], [], []]);
  }

  public static function shouldConvertComplexNestedArray(): Void {
    Assert.areEqual(LangParser.toAST('{{1, 2, 3}, {:a, :b, :c}, {"x", "y", "z"}}'), [[1,2,3], ['a'.atom(), 'b'.atom(), 'c'.atom()], ["x", "y", "z"]]);
  }

  public static function shouldThrowExceptionIfArrayStillOpen(): Void {
    Assert.throwsException(function(): Void { LangParser.toAST('{"foo", "bar", {1, 2, 3}, '); }, ParsingException);
  }

  public static function shouldThrowExceptionIfEncountersAClosingBracketWithNoOpenBracket(): Void {
    Assert.throwsException(function(): Void { LangParser.toAST('   }  '); }, ParsingException);
  }

  public static function shouldThrowExceptionIfEncounterTooManyClosingBrackets(): Void {
    Assert.throwsException(function(): Void { LangParser.toAST(' { }  } } }  '); }, ParsingException);
  }

  public static function shouldConvertHashToAst(): Void {
    Assert.areEqual(LangParser.toAST("%{      }"), {});
    Assert.areNotEqual(LangParser.toAST('"%{}"'), {});
  }

  public static function shouldConvertHashWithValues(): Void {
    Assert.areEqual(LangParser.toAST('%{"foo" => :bar}'), {'foo': 'bar'.atom()});
  }

  public static function shouldConvertHashWithNestedHashes(): Void {
    Assert.areEqual(LangParser.toAST('%{"foo" => :bar, "car" => %{}}'), {'foo': 'bar'.atom(), 'car': {}});
  }

  public static function shouldConvertHashWithHashKeys(): Void {
    var expect: Dynamic = {};
    var key: Dynamic = {};
    Reflect.setField(expect, key, "car");
    Assert.areEqual(LangParser.toAST('%{%{} => "car"}'), expect);
  }

  public static function shouldParseHashWithArrayValues(): Void {
    Assert.areEqual(LangParser.toAST('%{"foo" => :bar, "car" => {}}'), {'foo': 'bar'.atom(), 'car': []});
  }

  public static function shouldThrowParsingErrorIfHashIsLeftOpen(): Void {
    Assert.throwsException(function() { LangParser.toAST('%{:foo => "car"'); }, ParsingException);
  }

  public static function shouldParseAFunctionCallWithNoArgs(): Void {
    Assert.areEqual(LangParser.toAST('foo()'), ['foo'.atom(), [], []]);
  }

  public static function shouldThrowAnExceptionIfHasNoFunctionName(): Void {
    Assert.throwsException(function() { LangParser.toAST('()'); }, ParsingException);
  }

  public static function shouldParseAFunctionWithArgs(): Void {
    Assert.areEqual(LangParser.toAST('foo("bar", 1, 2, :three)'), ['foo'.atom(), [], ['bar', 1, 2, 'three'.atom()]]);
  }

  public static function shouldParseAFunctionWithNoParentheses(): Void {
    Assert.areEqual(LangParser.toAST('foo'), ['foo'.atom(), [], null]);
  }

  public static function shouldParseAFunctionArgsWithNoCommasOrParentheses(): Void {
    Assert.areEqual(LangParser.toAST('foo "bar" 1 cat :three'), ['foo'.atom(), [], ['bar', 1, ['cat'.atom(), [], null], 'three'.atom()]]);
  }

  public static function shouldParseAFunctionWithArgsAndNoParentheses(): Void {
    Assert.areEqual(LangParser.toAST('foo "bar", 1, cat, :three'), ['foo'.atom(), [], ['bar', 1, ['cat'.atom(), [], null], 'three'.atom()]]);
  }

  public static function shouldParseStringsWithNewLines(): Void {
    Assert.areEqual(LangParser.toAST('
    foo("bar", 1, 2, :three)
    :hash
    soo("baz", 3, 4, :five)
    "hello world"
    324
    {}
    coo("cat", 5, 6, :seven)
    %{}
'), [
      ['foo'.atom(), [], ['bar', 1, 2, 'three'.atom()]],
      'hash'.atom(),
      ['soo'.atom(), [], ['baz', 3, 4, 'five'.atom()]],
      "hello world",
      324,
      [],
      ['coo'.atom(), [], ['cat', 5, 6, 'seven'.atom()]],
      {}
    ]);
  }
}