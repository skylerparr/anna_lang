package tests;

import lang.LangParser;
import anna_unit.Assert;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class LangParserTest {

  public static function shouldExtractFunctionWithNoParenthesis(): Void {
    Assert.areEqual(LangParser.toAST('foo'), {val: 'foo', args: [], line: 1});
  }

  public static function shoudExtractFunctionWithTrailingWhitespace(): Void {
    Assert.areEqual(LangParser.toAST('foo  '), {val: 'foo', args: [], line: 1});
  }

  public static function shoudExtractFunctionWithPreceedingWhitespace(): Void {
    Assert.areEqual(LangParser.toAST('   foo'), {val: 'foo', args: [], line: 1});
  }

  public static function shoudExtractFunctionWithWhitespace(): Void {
    Assert.areEqual(LangParser.toAST('  foo  '), {val: 'foo', args: [], line: 1});
  }

  public static function shouldExtractFunctionWithParenthesis(): Void {
    Assert.areEqual(LangParser.toAST('foo()'), {val: 'foo', args: [], line: 1});
  }

  public static function shouldExtractFunctionWithOneConstantArg(): Void {
    Assert.areEqual(LangParser.toAST('foo(1)'), {val: 'foo', line: 1, args: [{ line: 1, val: 1, args: [] }]});
  }

  public static function shouldExtractFunctionWithTwoConstantArgs(): Void {
    Assert.areEqual(LangParser.toAST('foo(1, 2)'), {val: 'foo', line: 1, args: [{ line: 1, val: 1, args: [] }, { line: 1, val: 2, args: [] }]});
  }

  public static function shouldConvertFunctionWithNoParenthesis(): Void {
    Assert.areEqual(LangParser.toAST('foo 1, 2'), {val: 'foo', line: 1, args: [{ line: 1, val: 1, args: [] }, { line: 1, val: 2, args: [] }]});
  }

  public static function shouldConvertFunctionWithNestedFunction(): Void {
    Assert.areEqual(LangParser.toAST('foo(1, getFish())'),
      {val: 'foo', line: 1, args: [{ line: 1, val: 1, args: [] }, { line: 1, val: cast('getFish'), args: [] }]});
  }

  public static function shouldConvertFunctionWithNestedFunctionThatHasArgs(): Void {
    Assert.areEqual(LangParser.toAST('foo(1, getFish("foo"))'),
      {val: 'foo', line: 1, args: [{ line: 1, val: 1, args: [] }, { line: 1, val: cast('getFish'), args: [{ line: 1, val: '"foo"', args: [] }] }]});
  }

  public static function shouldConvertFunctionWithNestedFunctionThatHasArgsWithNoParenthesis(): Void {
    Assert.areEqual(LangParser.toAST('foo 1, getFish "foo"'),
      {val: 'foo', line: 1, args: [{ line: 1, val: 1, args: [] }, { line: 1, val: cast('getFish'), args: [{ line: 1, val: '"foo"', args: [] }] }]});
  }

  public static function shouldConvertToAtom(): Void {
    Assert.areEqual(LangParser.toAST(':foo'), {val: 'foo'.atom(), line: 1, args: []});
  }

  public static function shouldConvertFunctionWithNestedFunctionThatHasAtomArgs(): Void {
    Assert.areEqual(LangParser.toAST('foo(1, getFish(:foo))'),
    {val: 'foo', line: 1, args: [{ line: 1, val: 1, args: [] }, { line: 1, val: cast('getFish'), args: [{ line: 1, val: "foo".atom(), args: [] }] }]});
  }
}