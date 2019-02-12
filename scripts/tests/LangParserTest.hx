package tests;

import lang.LangParser;
import anna_unit.Assert;
import lang.LangParser;
import anna_unit.Assert;
import lang.LangParser;
import lang.ParsingException;
using lang.AtomSupport;
using StringTools;
@:build(macros.ScriptMacros.script())
class LangParserTest {

  public static function shouldLeaveExpressionUnchangedIfIsOnlyData(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('"foo"'), '"foo"');
    Assert.areEqual(LangParser.sanitizeExpr('549830'), '549830');
    Assert.areEqual(LangParser.sanitizeExpr('549.830'), '549.830');
    Assert.areEqual(LangParser.sanitizeExpr('%{"foo" => bar}'), '%{"foo" => bar}');
    Assert.areEqual(LangParser.sanitizeExpr('{"foo", bar}'), '{"foo",bar}');
    Assert.areEqual(LangParser.sanitizeExpr(':hello'), ':hello');
    Assert.areEqual(LangParser.sanitizeExpr('"fkjd \\" {ja dk: kfj ( (0 aikd) (() \\" }{{} []))  "'), '"fkjd \\" {ja dk: kfj ( (0 aikd) (() \\" }{{} []))  "');
  }

  public static function shouldLeaveExpressionUnchangedWithComposableFunctions(): Void {
    Assert.areEqual(LangParser.sanitizeExpr("foo()"), "foo()");
    Assert.areEqual(LangParser.sanitizeExpr("foo(1, 2, :cat)"), "foo(1,2,:cat)");
    Assert.areEqual(LangParser.sanitizeExpr("foo(cat(bear(hair())))"), "foo(cat(bear(hair())))");
  }

  public static function shouldAddParenthesisToObviousFunctionsWithNoParenthesis(): Void {
    Assert.areEqual(LangParser.sanitizeExpr("foo    :bar, baz, 123, 'kdfj', {1, 22, 333}   "), "foo(:bar,baz,123,'kdfj',{1,22,333})");
    Assert.areEqual(LangParser.sanitizeExpr("foo  (  :bar, baz, 123, 'kdfj', {1, 22, 333}  )   "), "foo(:bar,baz,123,'kdfj',{1,22,333})");
  }

  public static function shouldEcapsulateFunctionThatContainsNestedFunctionsAndData(): Void {
    Assert.areEqual(LangParser.sanitizeExpr("foo  (  :bar, baz( {:foo, mars}), 123, 'kdfj', {1, 22, 333}   )   "), "foo(:bar,baz({:foo,mars}),123,'kdfj',{1,22,333})");
  }

  public static function shouldIgnoreBracesParensAndCommasIfArgIsString(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('foo(398, "akdfj{},)((0)0al,kd-3),[]((((", bar(:baz,        cat(),        foo(),     more_cat()    )   )'),
    'foo(398,"akdfj{},)((0)0al,kd-3),[]((((",bar(:baz,cat(),foo(),more_cat()))');
  }

  public static function shouldIgnoreLeftRightOperatorsIfArgIsString(): Void {
    Assert.areEqual(LangParser.sanitizeExpr(':"foo + 23"'), ':"foo + 23"');
  }

  public static function shouldExtractLeftRightFunctionsIntoStandardFunctionCalls(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('foo.bar'), '.(foo,bar)');
    Assert.areEqual(LangParser.sanitizeExpr('foo +   \n bar'), '+(foo,bar)');
    Assert.areEqual(LangParser.sanitizeExpr('560 - 389'), '-(560,389)');
    Assert.areEqual(LangParser.sanitizeExpr('560 - abc'), '-(560,abc)');
    Assert.areEqual(LangParser.sanitizeExpr('def - 123'), '-(def,123)');
    Assert.areEqual(LangParser.sanitizeExpr('a + b'), '+(a,b)');
  }

  public static function shouldHandleMultipleLeftRightFunctionsOfTheSameOperator(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('foo.bar.cat'), '.(foo,.(bar,cat))');
    Assert.areEqual(LangParser.sanitizeExpr('foo.bar.cat.baz.boo'), '.(foo,.(bar,.(cat,.(baz,boo))))');
    Assert.areEqual(LangParser.sanitizeExpr('1+2'), '+(1,2)');
    Assert.areEqual(LangParser.sanitizeExpr('baz(1 + 2)'), 'baz(+(1,2))');
    Assert.areEqual(LangParser.sanitizeExpr('foo + bar + cat(1, abc, :three) + baz(2 + 1) + boo'), '+(foo,+(bar,+(cat(1,abc,:three),+(baz(+(2,1)),boo))))');
  }

  public static function shouldHandleOperatorsThatAreMoreThanOneCharacter(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('221 >= 532'), '>=(221,532)');
    Assert.areEqual(LangParser.sanitizeExpr('124<=987'), '<=(124,987)');
    Assert.areEqual(LangParser.sanitizeExpr('abc>=532'), '>=(abc,532)');
    Assert.areEqual(LangParser.sanitizeExpr('325>=def'), '>=(325,def)');
    Assert.areEqual(LangParser.sanitizeExpr('abc >=def && hij<= 849 || klm == 4903'), '>=(abc,&&(def,<=(hij,||(849,==(klm,4903)))))');
  }

  public static function shouldSanitizeFunctionArgsWithLeftRightFunctions(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('cook(     abc  -   xyz , def +    212   , cat()   )  '), 'cook(-(abc,xyz),+(def,212),cat())');
  }

  public static function shouldSanitizeMultipleNestedLeftRightFunctions(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('%{"cost" => pza} = cook(a, b + 212)'), '=(%{"cost" => pza},cook(a,+(b,212)))');
  }

  public static function shouldSanitizeFunctionWithNoParensButHasCommas(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('foo "bar", 1, cat, :three'), 'foo("bar",1,cat,:three)');
    Assert.areEqual(LangParser.sanitizeExpr('inject Ellie, :bear'), 'inject(Ellie,:bear)');
  }

  public static function shouldSanitizeFunctionWithNoParensAndNoCommas(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('foo    "bar"   1   cat()     :three'), 'foo("bar",1,cat(),:three)');
  }

  public static function shouldIgnoreAllCharactersAfterHash(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('#world'), '');
    Assert.areEqual(LangParser.sanitizeExpr('hello#world'), 'hello');
  }

  public static function shouldSanitizeWithArrayArgs(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('m(3, a({1, 2}))'), 'm(3,a({1,2}))');
  }

  public static function shouldSantizeLeftRightWithinFunction(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('if(abc > def)'), 'if(>(abc,def))');
  }

  public static function shouldSanitizeMultipleExpressions(): Void {
    Assert.areEqual(LangParser.sanitizeExpr('
    foo("bar", 1, 2, :three)
    :hash
    soo("baz", 3, 4, :five)
    "hello world"
    324
    {}
    a +  b
    rem(a, b)
    cook(a, b + 212)
    a + b
    coo("cat", 5, 6, :seven)
    %{}'),
'foo("bar",1,2,:three)
:hash
soo("baz",3,4,:five)
"hello world"
324
{}
+(a,b)
rem(a,b)
cook(a,+(b,212))
+(a,b)
coo("cat",5,6,:seven)
%{}');
  }

  public static function shouldSanitizeNestedExpressionsWithDo(): Void {
    var expr: String = '
defmodule Foo do
  @spec(order, {Int, Int}, Int)
  def order(a, b) do
    rem(a, b)
    Foo
    Foo
    cook(a, b + 212)
    a + b
  end
end          ';
    Assert.areEqual(LangParser.sanitizeExpr(expr), 'defmodule(Foo,do(@spec(order, {Int, Int}, Int)
  def order(a, b) do
    rem(a, b)
    Foo
    Foo
    cook(a, b + 212)
    a + b
  end))');
  }

  public static function shouldSanitizeFunctionWithDo(): Void {
    var expr: String = 'if(abc > def   )     do        
  foo(1 + 3)
  face()
end';
    Assert.areEqual(LangParser.sanitizeExpr(expr), 'if(>(abc,def),do(foo(+(1,3)),face())');

    expr = 'if(ellie > 5) do
      inject Ellie, :bear
    end';

    Assert.areEqual(LangParser.sanitizeExpr(expr), 'if(>(ellie,5),do(inject Ellie, :bear))');
  }

  public static function shouldSanitizeMultipleDoBlocks(): Void {
    var expr: String = '
  @spec(bar, null, Dynamic)
  def bar() do
    :cat
    :bear
  end

  @spec(cat, null, Dynamic)
  def cat() do
    :baz
  end

  @spec(ellie, null, Dynamic)
  def ellie() do
    :bear
  end
';
    Assert.areEqual(LangParser.sanitizeExpr(expr), '@spec(bar,null,Dynamic)
def(bar(),do(:cat
    :bear))
@spec(cat,null,Dynamic)
def(cat(),do(:baz))
@spec(ellie,null,Dynamic)
def(ellie(),do(:bear))');
  }

  public static function shouldSanitizeMultipleNestedDoBlocks(): Void {
    var expr: String = 'defmodule Foo do
  def bar() do
    :cat
    :bear
  end

  def cat() do
    :baz
  end

  def ellie() do
    :bear
  end
end';
    Assert.areEqual(LangParser.sanitizeExpr(expr), 'defmodule(Foo,do(def bar() do
    :cat
    :bear
  end

  def cat() do
    :baz
  end

  def ellie() do
    :bear
  end))');
  }

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

  public static function shouldConvertHashWithAtomKeys(): Void {
    var expect: Dynamic = {};
    var key: Dynamic = 'foo'.atom();
    Reflect.setField(expect, key, 'bar'.atom());
    Assert.areEqual(LangParser.toAST('%{:foo => :bar}'), expect);
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

  public static function shouldParseAtFunctionWhenOneOfTheArgsIsAnArray(): Void {
    Assert.areEqual(LangParser.toAST('@spec(mod, {Int, Int}, Float)'),
    ['at_spec'.atom(), [], [['mod'.atom(), [], null], [['Int'.atom(), [], null], ['Int'.atom(), [], null]], ['Float'.atom(), [], null]]]);
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

    var expr: String = '@spec(order,{String,String},Dynamic)
def order(ellie,bear) do
  inject Ellie, :bear
end
def hello(a) do
  "hello world"
end';
    var specBlock: Array<Dynamic> = ['at_spec'.atom(),[],[['order'.atom(),[],null],[['String'.atom(),[],null],['String'.atom(),[],null]],['Dynamic'.atom(),[],null]]];
    var orderBody: Array<Dynamic> = [['inject'.atom(),[],[['Ellie'.atom(),[],null],'bear'.atom()]]];
    var orderBlock: Array<Dynamic> = ['def'.atom(),[],[['order'.atom(),[],[['ellie'.atom(),[],null],['bear'.atom(),[],null]]],{ __block__: orderBody }]];
    var helloBlock: Array<Dynamic> = ['def'.atom(),[],[['hello'.atom(),[],[['a'.atom(),[],null]]],{ __block__: ["hello world"] }]];
    Assert.areEqual(LangParser.toAST(expr), { __block__: [specBlock, orderBlock, helloBlock] });
  }

  public static function shouldIgnoreCommentedLines(): Void {
    Assert.areEqual(LangParser.toAST('# this is a comment'), []);
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

  public static function shouldParseAssigningFunctionToAPattern(): Void {
    var string: String = '%{"cost" => pza} = cook(a, b + 212)';
    var cost: Dynamic = {};
    var value: Dynamic = ["pza".atom(), [], null];
    Reflect.setField(cost, 'cost', value);
    Assert.areEqual(LangParser.toAST(string),
      ['='.atom(), [], [cost, ['cook'.atom(), [], [['a'.atom(), [], null], ['+'.atom(), [], [['b'.atom(), [], null], 212]]]]]]);
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

  public static function shouldHandleNestedBlocksWhenFunctionsHaveArgs(): Void {
    var expr: String = '
defmodule Foo do
  @spec(order, {String, String}, Dynamic)
  def order(ellie, bear) do
    inject Ellie, :bear
  end

  def hello(a) do
    "hello world"
  end
end';
    var helloBody: Array<Dynamic> = ["hello world"];
    var orderBody: Array<Dynamic> = [['inject'.atom(),[],[['Ellie'.atom(),[],null],'bear'.atom()]]];
    var moduleBody: Array<Dynamic> = [['at_spec'.atom(),[],[['order'.atom(),[],null],[['String'.atom(),[],null],['String'.atom(),[],null]],['Dynamic'.atom(),[],null]]],['def'.atom(),[],[['order'.atom(),[],[['ellie'.atom(),[],null],['bear'.atom(),[],null]]],{ __block__: orderBody }]],['def'.atom(),[],[['hello'.atom(),[],[['a'.atom(),[],null]]],{ __block__: helloBody}]]];
    Assert.areEqual(LangParser.toAST(expr), ['defmodule'.atom(),[],[['Foo'.atom(),[],null],{ __block__: moduleBody }]]);
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
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(':pretty')), '"pretty".atom()');
  }

  public static function shouldConvertArrayASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('{}')), '[]');
  }

  public static function shouldConvertArrayWithValuesToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('{2,  :foo, "house", 292}')), '[2, "foo".atom(), "house", 292]');
  }

  public static function shouldConvertHashASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('%{}')), '{}');
  }

  public static function shouldConvertHashWithValuesASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('%{"foo" => :bar, "car" => {}}')), '{"car": [], "foo": "bar".atom()}');
  }

  public static function shouldConvertVariableToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('foobee')), 'foobee');
  }

  public static function shouldConvertFunctionCallASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('foo()')), 'foo()');
  }

  public static function shouldConvertFunctionCallWithArgsFromASTToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST('foo(1, :two, three)')), 'foo(1, "two".atom(), three)');
  }

  public static function shouldParseFunctionWithNestedFunctionCallsAndDataStructuresToHaxe(): Void {
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(
      'm(3, b(1, 2), ellie({:foo}), qtip(nozy(%{"bar" => {:cat}})))')),
      'm(3, b(1, 2), ellie(["foo".atom()]), qtip(nozy({"bar": ["cat".atom()]})))');
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
    rem(a, b)
    cook(a, b + 212)
    a + b
    #%{cost => pza} = cook(a, b + 212)
    cost
    %{}')),
    'foo("bar", 1, 2, "three".atom())
"hash".atom()
soo("baz", 3, 4, "five".atom())
"hello world"
324
[]
coo("cat", 5, 6, "seven".atom())
rem(a, b)
cook(a, Anna.add(b, 212))
Anna.add(a, b)
cost
{}');
  }

  public static function shouldCallDefmoduleMacro(): Void {
    var string: String = "defmodule Foo do end";
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(string)),
      'package;
using lang.AtomSupport;
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
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function bar() {

    
    return "nil".atom();
  }
}'
    );
  }

  public static function shouldCallDefMacroWithSingleExpression(): Void {
    var string: String = "defmodule Foo do
      def bar() do
        1 + 2
      end
    end";
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(string)),
    'package;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function bar() {

    
    return Anna.add(1, 2);
  }
}'
    );
  }

  public static function shouldCallDefMacroAndReturnAtom(): Void {
    var string: String = 'defmodule Foo do
      def cat() do
        "hello cat"
      end

      def bar() do
        :success
      end
    end';
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(string)),
    'package;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function cat() {

    
    return "hello cat";
  }
  public static function bar() {

    
    return "success".atom();
  }
}'
    );
  }

  public static function shouldHandleMultipleExpressions(): Void {
    var string: String = "
    defmodule Foo do
      @spec(order, {Int, Int}, Int)
      def order(a, b) do
        rem(a, b)
        cook(a, b + 212)
        a + b
      end
    end";
    Assert.areEqual(LangParser.toHaxe(LangParser.toAST(string)),
    'package;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function order(arg0: Int, arg1: Int): Int {
    var a: Int;
    var b: Int;
    switch([arg0, arg1]) {
      case _:
        a = arg0;
        b = arg1;
    }
    var v0 = rem(a, b);
    var v1 = cook(a, Anna.add(b, 212));
    return Anna.add(a, b);
  }
}'
    );
  }
}