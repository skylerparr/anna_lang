package tests;

import lang.LangParser;
import lang.LangParser;
import lang.LangParser;
import lang.LangParser;
import lang.LangParser;
import lang.Types;
import lang.ParsingException;
import lang.LangParser;
import anna_unit.Assert;
using lang.AtomSupport;
using StringTools;
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

  public static function shouldConvertFloatingPointNumberToAst(): Void {
    Assert.areEqual(LangParser.toAST("12.3"), 12.3);
    Assert.areEqual(LangParser.toAST(".3"), .3);
    Assert.areEqual(LangParser.toAST("  1.23  "), 1.23);

    Assert.areNotEqual(LangParser.toAST('"12.3"'), 12.3);
    Assert.areNotEqual(LangParser.toAST('1.23'), '1.23');
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

  public static function shouldParseAnAtomWithDots(): Void {
    Assert.areEqual(LangParser.toAST('Foo.Bar.Cat'), ['.'.atom(),[],[['Foo'.atom(),[],null],['.'.atom(),[],[['Bar'.atom(),[],null],['Cat'.atom(),[],null]]]]]);
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

  public static function shouldThrowExceptionIfEncountersAClosingBracketWithNoOpenBraces(): Void {
    Assert.throwsException(function(): Void { LangParser.toAST('   }  '); }, ParsingException);
  }

  public static function shouldThrowExceptionIfEncounterTooManyClosingBraces(): Void {
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

  public static function shouldParseAFunctionWithNoParenthesesAndSurroundedWithWhitespace(): Void {
    Assert.areEqual(LangParser.toAST('   foo   '), ['foo'.atom(), [], null]);
  }

  public static function shouldParseASingleLetterFunction(): Void {
    Assert.areEqual(LangParser.toAST('a '), ['a'.atom(), [], null]);
  }

  public static function shouldParseAFunctionArgsWithNoCommasOrParentheses(): Void {
    Assert.areEqual(LangParser.toAST('foo "bar" 1 cat :three'), ['foo'.atom(), [], ['bar', 1, ['cat'.atom(), [], null], 'three'.atom()]]);
  }

  public static function shouldParseAFunctionWithArgsAndNoParentheses(): Void {
    Assert.areEqual(LangParser.toAST('foo "bar", 1, cat, :three'), ['foo'.atom(), [], ['bar', 1, ['cat'.atom(), [], null], 'three'.atom()]]);
  }

  public static function shouldParseFunctionWith2VarArgs(): Void {
    Assert.areEqual(LangParser.toAST('foo a, b'), ['foo'.atom(), [], [['a'.atom(), [], null], ['b'.atom(), [], null]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCalls(): Void {
    Assert.areEqual(LangParser.toAST('m(3, a(1, 2))'), ['m'.atom(), [], [3, ['a'.atom(), [], [1,2]]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCallThatHasArrayArgs(): Void {
    Assert.areEqual(LangParser.toAST('m(3, a({1, 2}))'), ['m'.atom(), [], [3, ['a'.atom(), [], [[1,2]]]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCallThatHasHashArgs(): Void {
    Assert.areEqual(LangParser.toAST('m(3, a(%{"b" => "ellie"}))'), ['m'.atom(), [], [3, ['a'.atom(), [], [{"b": "ellie"}]]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCallThatHasASingleHashArg(): Void {
    Assert.areEqual(LangParser.toAST('nozy(%{"bar" => {:cat}})'), ['nozy'.atom(), [], [{"bar": ['cat'.atom()]}]]);
  }

  public static function shouldParseFunctionWithMultipleNestedFunctionCallsThatHasHashArgs(): Void {
    Assert.areEqual(LangParser.toAST('qtip(nozy(%{"bar" => {:cat}}))'), ['qtip'.atom(), [], [['nozy'.atom(), [], [{"bar": ['cat'.atom()]}]]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCallsAndDataStructures(): Void {
    Assert.areEqual(LangParser.toAST('m(3, b(1, 2), ellie({:foo}), qtip(nozy(%{"bar" => {:cat}})))'),
      ['m'.atom(), [], [3, ['b'.atom(), [], [1,2]], ['ellie'.atom(), [], [['foo'.atom()]]],
        ['qtip'.atom(), [], [['nozy'.atom(), [], [{'bar': ['cat'.atom()]}]]]]]]);
  }

  public static function shouldParseMultipleExpressions(): Void {
    var expectation: Dynamic<Array<Dynamic>> = {__block__: [
      ['foo'.atom(), [], ['bar', 1, 2, 'three'.atom()]],
      'hash'.atom(),
      ['soo'.atom(), [], ['baz', 3, 4, 'five'.atom()]],
      "hello world",
      324,
      [],
      ['coo'.atom(), [], ['cat', 5, 6, 'seven'.atom()]],
      {}
    ]};

    Assert.areEqual(LangParser.toAST('
    foo("bar", 1, 2, :three)
    :hash
    soo("baz", 3, 4, :five)
    "hello world"
    324
    {}
    coo("cat", 5, 6, :seven)
    %{}
    '), expectation);
  }

  public static function shouldParseAddOperatorsIntoFunctions(): Void {
    Assert.areEqual(LangParser.toAST("1 + 2"), ['+'.atom(), [], [1, 2]]);
  }

  public static function shouldParseSubtractOperatorsIntoFunctions(): Void {
    Assert.areEqual(LangParser.toAST("1 - 2"), ['-'.atom(), [], [1, 2]]);
  }

  public static function shouldParseMultiplyOperatorsIntoFunctions(): Void {
    Assert.areEqual(LangParser.toAST("1 * 2"), ['*'.atom(), [], [1, 2]]);
  }

  public static function shouldParseDivideOperatorsIntoFunctions(): Void {
    Assert.areEqual(LangParser.toAST("1 / 2"), ['/'.atom(), [], [1, 2]]);
  }

  public static function shouldParseEqualsOperatorsIntoFunctions(): Void {
    Assert.areEqual(LangParser.toAST("1 = 2"), ['='.atom(), [], [1, 2]]);
  }

  public static function shouldParseEqualsOperatorsWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("a=b"), ['='.atom(), [], [['a'.atom(), [] , null], ['b'.atom(), [], null]]]);
    Assert.areEqual(LangParser.toAST("a = 1"), ['='.atom(), [], [['a'.atom(), [] , null], 1]]);
  }

  public static function shouldParseGreaterThanOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("a>b"), ['>'.atom(), [], [['a'.atom(), [] , null], ['b'.atom(), [], null]]]);
    Assert.areEqual(LangParser.toAST("a > 1"), ['>'.atom(), [], [['a'.atom(), [] , null], 1]]);
  }

  public static function shouldParseLessThanOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("a<b"), ['<'.atom(), [], [['a'.atom(), [] , null], ['b'.atom(), [], null]]]);
    Assert.areEqual(LangParser.toAST("a < 1"), ['<'.atom(), [], [['a'.atom(), [] , null], 1]]);
  }

  public static function shouldParsePlusOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc + xyz"), ['+'.atom(), [], [['abc'.atom(), [] , null], ['xyz'.atom(), [], null]]]);
    Assert.areEqual(LangParser.toAST("abc + 224"), ['+'.atom(), [], [['abc'.atom(), [] , null], 224]]);
  }

  public static function shouldParseMultipleOperators(): Void {
    Assert.areEqual(LangParser.toAST("abc + xyz - 15 * 29"), ['+'.atom(),[],[['abc'.atom(),[],null], ['-'.atom(),[],[['xyz'.atom(),[],null], ['*'.atom(),[],[15,29]]]]]]);
  }

  public static function shouldParseMinusOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc - xyz"), ['-'.atom(), [], [['abc'.atom(), [] , null], ['xyz'.atom(), [], null]]]);
  }

  public static function shouldParseMultiplyOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc * xyz"), ['*'.atom(), [], [['abc'.atom(), [] , null], ['xyz'.atom(), [], null]]]);
  }

  public static function shouldParseDivideOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc / xyz"), ['/'.atom(), [], [['abc'.atom(), [] , null], ['xyz'.atom(), [], null]]]);
  }

  public static function shouldParseDoubleEqualsOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc == xyz"), ['=='.atom(), [], [['abc'.atom(), [] , null], ['xyz'.atom(), [], null]]]);
  }

  public static function shouldParseStabbyOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc -> xyz"), ['->'.atom(), [], [['abc'.atom(), [] , null], ['xyz'.atom(), [], null]]]);
  }

  public static function shouldHandleDotAsOperator(): Void {
    Assert.areEqual(LangParser.toAST("foo.bar"), ['.'.atom(), [], [['foo'.atom(), [] , null], ['bar'.atom(), [], null]]]);
  }

  public static function shouldHandleGreaterThanOrEqualOperator(): Void {
    Assert.areEqual(LangParser.toAST("foo >= bar"), ['>='.atom(), [], [['foo'.atom(), [] , null], ['bar'.atom(), [], null]]]);
    Assert.areEqual(LangParser.toAST("ellie>=bear"), ['>='.atom(), [], [['ellie'.atom(), [] , null], ['bear'.atom(), [], null]]]);
  }

  public static function shouldHandleLessThanOrEqualOperator(): Void {
    Assert.areEqual(LangParser.toAST("foo <= bar"), ['<='.atom(), [], [['foo'.atom(), [] , null], ['bar'.atom(), [], null]]]);
    Assert.areEqual(LangParser.toAST("ellie<=bear"), ['<='.atom(), [], [['ellie'.atom(), [] , null], ['bear'.atom(), [], null]]]);
  }

  public static function shouldParseDoAndEndAsAST(): Void {
    var string: String = "
      defmodule Foo do
      end
    ";
    Assert.areEqual(LangParser.toAST(string), ['defmodule'.atom(), [], [['Foo'.atom(), [], null], {__block__: []}]]);

    var string: String = "
      defmodule Foo do
        inject Ellie, :bear
      end
    ";

    var doBlock: Array<Dynamic> = ['inject'.atom(),[],[['Ellie'.atom(),[],null],'bear'.atom()]];
    Assert.areEqual(LangParser.toAST(string), ['defmodule'.atom(), [], [['Foo'.atom(), [], null], {__block__: [doBlock]}]]);
  }

  public static function shouldHandleDoBlocksWithParens(): Void {
    var string: String = "
      if(a > 29) do
        inject Ellie, :bear
      end
    ";

    var doBlock: Array<Dynamic> = ['inject'.atom(),[],[['Ellie'.atom(),[],null],'bear'.atom()]];
    Assert.areEqual(LangParser.toAST(string), ['if'.atom(),[],[['>'.atom(),[],[['a'.atom(),[],null],29]], {__block__: [doBlock]}]]);
  }

  public static function shouldHandleNestedDoBlocks(): Void {
    var string: String = "
      defmodule Foo do
        def bar() do
          if(ellie > 5) do
            inject Ellie, :bear
          end
        end
      end
    ";
    var doIfBody: Array<Dynamic> = ['inject'.atom(),[],[['Ellie'.atom(),[],null],'bear'.atom()]];
    var doDefBody: Array<Dynamic> = ['if'.atom(),[],[['>'.atom(),[],[['ellie'.atom(),[],null],5]], {__block__: [doIfBody]}]];
    var doModuleBody: Array<Dynamic> = ['def'.atom(),[],[['bar'.atom(),[], []], {__block__: [doDefBody]}]];
    Assert.areEqual(LangParser.toAST(string), ['defmodule'.atom(), [], [['Foo'.atom(), [], null], {__block__: [doModuleBody]}]]);
  }

  public static function shouldConvertStringASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('"foo"')), '"foo"');
  }

  public static function shouldConvertEscapedStringASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('"foo\\"s"')), '"foo"s"');
  }

  public static function shouldConvertNumberASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('3412')), '3412');
  }

  public static function shouldConvertFloatingPointNumberASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('34.12')), '34.12');
  }

  public static function shouldConvertAtomASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(':pretty')), '${'pretty'.atom()}');
  }

  public static function shouldConvertArrayASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('{}')), '[]');
  }

  public static function shouldConvertArrayWithValuesToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('{2,  :foo, "house", 292}')), '[2, ${'foo'.atom()}, "house", 292]');
  }

  public static function shouldConvertHashASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('%{}')), '{}');
  }

  public static function shouldConvertHashWithValuesASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('%{"foo" => :bar, "car" => {}}')), '{"car": [], "foo": ${'bar'.atom()}}');
  }

  public static function shouldConvertVariableToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('foobee')), 'foobee');
  }

  public static function shouldConvertFunctionCallASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('foo()')), 'foo()');
  }

  public static function shouldConvertFunctionCallWithArgsFromASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('foo(1, :two, three)')), 'foo(1, ${'two'.atom()}, three)');
  }

  public static function shouldParseFunctionWithNestedFunctionCallsAndDataStructuresToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(
      'm(3, b(1, 2), ellie({:foo}), qtip(nozy(%{"bar" => {:cat}})))')),
      'm(3, b(1, 2), ellie([${'foo'.atom()}]), qtip(nozy({"bar": [${'cat'.atom()}]})))');
  }

  public static function shouldSubstituteAliasedFunctionsWhenConvertingToHaxe(): Void {
    var aliases: Map<String, String> = new Map<String, String>();
    aliases.set('+', 'add');
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(
      '193 + 230'), aliases), 'add(193, 230)');
  }

  public static function shouldConvertMultipleStatementsToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('
    foo("bar", 1, 2, :three)
    :hash
    soo("baz", 3, 4, :five)
    "hello world"
    324
    {}
    coo("cat", 5, 6, :seven)
    %{}')),
    'foo("bar", 1, 2, ${'three'.atom()})
${'hash'.atom()}
soo("baz", 3, 4, ${'five'.atom()})
"hello world"
324
[]
coo("cat", 5, 6, ${'seven'.atom()})
{}');
  }

  public static function shouldCallDefmoduleMacro(): Void {
    var string: String = "defmodule Foo do end";
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(string)),
      'package;
@:build(macros.ScriptMacros.script())
class Foo {

}'
    );
  }

  public static function shouldCallDefMacro(): Void {
    var string: String = "defmodule Foo do
      def bar() do
      end
    end";
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(string)),
    'package;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function bar() {
    
  }
}'
    );
  }

  public static function shouldFillInFunctionBodyForDef(): Void {
    var string: String = "defmodule Foo do
      def mod(a, b) do
        rem(a, b)
      end
    end";
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(string)),
    'package;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function mod(a, b) {
    return rem(a, b);
  }
}'
    );
  }
}