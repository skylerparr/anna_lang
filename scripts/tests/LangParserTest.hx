package tests;

import lang.LangParser;
import anna_unit.Assert;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class LangParserTest {

  public static function shouldExtractFunctionWithNoParenthesis(): Void {
    Assert.areEqual(LangParser.toAST('foo'), {func: 'foo'.atom(), args: [], line: 1});
  }

  public static function shoudExtractFunctionWithTrailingWhitespace(): Void {
    Assert.areEqual(LangParser.toAST('foo  '), {func: 'foo'.atom(), args: [], line: 1});
  }

  public static function shoudExtractFunctionWithPreceedingWhitespace(): Void {
    Assert.areEqual(LangParser.toAST('   foo'), {func: 'foo'.atom(), args: [], line: 1});
  }

  public static function shoudExtractFunctionWithWhitespace(): Void {
    Assert.areEqual(LangParser.toAST('  foo  '), {func: 'foo'.atom(), args: [], line: 1});
  }

  public static function shouldExtractFunctionWithParenthesis(): Void {
    Assert.areEqual(LangParser.toAST('foo()'), {func: 'foo'.atom(), args: [], line: 1});
  }

  public static function shouldExtractFunctionWithOneConstantArg(): Void {
    Assert.areEqual(LangParser.toAST('foo(1)'), {func: 'foo'.atom(), line: 1, args: [1]});
  }
}