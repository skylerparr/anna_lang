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
    Assert.areNotEqual(LangParser.toAST('":foo"'), "foo".atom());
  }

  public static function shouldConvertAtomInQuote(): Void {
    Assert.areEqual(LangParser.toAST(':"foo + 1"'), '"foo + 1"'.atom());
  }

  public static function shouldConvertArrayToAst(): Void {
    Assert.areEqual(LangParser.toAST("[    ]"), []);
    Assert.areNotEqual(LangParser.toAST('"[]"'), []);
  }

  public static function shouldConvertArrayWithValues(): Void {
    Assert.areEqual(LangParser.toAST('[  2,  :foo  , "house"  , 292  ]'), [2, 'foo'.atom(), 'house', 292]);
  }

  public static function shouldConvertArrayWithValuesWithTrailingComma(): Void {
    Assert.areEqual(LangParser.toAST('[  2,  :foo  , "house"  , 292  ,  ]'), [2, 'foo'.atom(), 'house', 292]);
  }

  public static function shouldConvertArrayWithNestedArrays(): Void {
    Assert.areEqual(LangParser.toAST('[[]]'), [[]]);
    Assert.areEqual(LangParser.toAST('[[], [], []]'), [[], [], []]);
  }

  public static function shouldConvertComplexNestedArray(): Void {
    Assert.areEqual(LangParser.toAST('[[1, 2, 3], [:a, :b, :c], ["x", "y", "z"]]'), [[1,2,3], ['a'.atom(), 'b'.atom(), 'c'.atom()], ["x", "y", "z"]]);
  }
//
//  public static function shouldConvertHashToAst(): Void {
//    Assert.areEqual(LangParser.toAST("{      }"), {});
//    Assert.areNotEqual(LangParser.toAST('"{}"'), {});
//  }
}