package tests;

import anna_unit.Assert;
import haxe.ds.ObjectMap;
import lang.LangParser;
import lang.Module;
import lang.ParsingException;
using lang.AtomSupport;
using StringTools;
@:build(macros.ScriptMacros.script())
class LangParserTest {

  private static var emptyMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();

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

    expr = 'if(ellie > 5 && bear < ellie) do
      inject Ellie, :bear
    end';

    Assert.areEqual(LangParser.sanitizeExpr(expr), 'if(>(ellie,&&(5,<(bear,ellie))),do(inject Ellie, :bear))');
  }

  public static function shouldSanitizeMultipleDoBlocks(): Void {
    var expr: String = '
  @spec(bar, nil, Dynamic)
  def bar() do
    :cat
    :bear
  end

  @spec(cat, nil, Dynamic)
  def cat() do
    :baz
  end

  @spec(ellie, nil, Dynamic)
  def ellie() do
    :bear
  end
';
    Assert.areEqual(LangParser.sanitizeExpr(expr), '@spec(bar,nil,Dynamic)
def(bar(),do(:cat
    :bear))
@spec(cat,nil,Dynamic)
def(cat(),do(:baz))
@spec(ellie,nil,Dynamic)
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

  public static function shouldSanitizeMultipleLeftRightOperatorsWithTrailingDoEnd(): Void {
    var string: String = 'defmodule Foo.Bar.Cat.Baz.Car do
  inject Ellie, :bear
end';
    Assert.areEqual(LangParser.sanitizeExpr(string), 'defmodule(.(Foo,.(Bar,.(Cat,.(Baz,Car)))),do(inject Ellie, :bear))');
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
    Assert.areEqual(LangParser.toAST('Foo.Bar.Cat'), ['.'.atom(),[],[['Foo'.atom(),[],'nil'.atom()],['.'.atom(),[],[['Bar'.atom(),[],'nil'.atom()],['Cat'.atom(),[],'nil'.atom()]]]]]);
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
    Assert.areEqual(LangParser.toAST("%{      }"), emptyMap);
    Assert.areNotEqual(LangParser.toAST('"%{}"'), emptyMap);
  }

  public static function shouldConvertHashWithValues(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('foo', 'bar'.atom());
    Assert.areEqual(LangParser.toAST('%{"foo" => :bar}'), map);
  }

  public static function shouldConvertHashWithAtomKeys(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('foo'.atom(), 'bar'.atom());
    Assert.areEqual(LangParser.toAST('%{:foo => :bar}'), map);
  }

  public static function shouldConvertHashWithNestedHashes(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('foo', 'bar'.atom());
    map.set('car', emptyMap);
    Assert.areEqual(LangParser.toAST('%{"foo" => :bar, "car" => %{}}'), map);
  }

  public static function shouldConvertHashWithHashKeys(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set(emptyMap, "car");
    Assert.areEqual(LangParser.toAST('%{%{} => "car"}'), map);
  }

  public static function shouldParseHashWithArrayValues(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('foo', 'bar'.atom());
    map.set('car', []);
    Assert.areEqual(LangParser.toAST('%{"foo" => :bar, "car" => {}}'), map);
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
    Assert.areEqual(LangParser.toAST('foo'), ['foo'.atom(), [], 'nil'.atom()]);
  }

  public static function shouldParseAFunctionWithNoParenthesesAndSurroundedWithWhitespace(): Void {
    Assert.areEqual(LangParser.toAST('   foo   '), ['foo'.atom(), [], 'nil'.atom()]);
  }

  public static function shouldParseASingleLetterFunction(): Void {
    Assert.areEqual(LangParser.toAST('a '), ['a'.atom(), [], 'nil'.atom()]);
  }

  public static function shouldParseAFunctionArgsWithNoCommasOrParentheses(): Void {
    Assert.areEqual(LangParser.toAST('foo "bar" 1 cat :three'), ['foo'.atom(), [], ['bar', 1, ['cat'.atom(), [], 'nil'.atom()], 'three'.atom()]]);
  }

  public static function shouldParseAFunctionWithArgsAndNoParentheses(): Void {
    Assert.areEqual(LangParser.toAST('foo "bar", 1, cat, :three'), ['foo'.atom(), [], ['bar', 1, ['cat'.atom(), [], 'nil'.atom()], 'three'.atom()]]);
  }

  public static function shouldParseFunctionWith2VarArgs(): Void {
    Assert.areEqual(LangParser.toAST('foo a, b'), ['foo'.atom(), [], [['a'.atom(), [], 'nil'.atom()], ['b'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCalls(): Void {
    Assert.areEqual(LangParser.toAST('m(3, a(1, 2))'), ['m'.atom(), [], [3, ['a'.atom(), [], [1,2]]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCallThatHasArrayArgs(): Void {
    Assert.areEqual(LangParser.toAST('m(3, a({1, 2}))'), ['m'.atom(), [], [3, ['a'.atom(), [], [[1,2]]]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCallThatHasHashArgs(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('b', 'ellie');
    Assert.areEqual(LangParser.toAST('m(3, a(%{"b" => "ellie"}))'), ['m'.atom(), [], [3, ['a'.atom(), [], [map]]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCallThatHasASingleHashArg(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('bar', ['cat'.atom()]);
    Assert.areEqual(LangParser.toAST('nozy(%{"bar" => {:cat}})'), ['nozy'.atom(), [], [map]]);
  }

  public static function shouldParseFunctionWithMultipleNestedFunctionCallsThatHasHashArgs(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set('bar', ['cat'.atom()]);    Assert.areEqual(LangParser.toAST('qtip(nozy(%{"bar" => {:cat}}))'), ['qtip'.atom(), [], [['nozy'.atom(), [], [map]]]]);
  }

  public static function shouldParseFunctionWithNestedFunctionCallsAndDataStructures(): Void {
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    map.set("bar", ['cat'.atom()]);

    Assert.areEqual(LangParser.toAST('m(3, b(1, 2), ellie({:foo}), qtip(nozy(%{"bar" => {:cat}})))'),
      ['m'.atom(), [], [3, ['b'.atom(), [], [1,2]], ['ellie'.atom(), [], [['foo'.atom()]]],
        ['qtip'.atom(), [], [['nozy'.atom(), [], [map]]]]]]);
  }

  public static function shouldParseAtFunctionWhenOneOfTheArgsIsAnArray(): Void {
    Assert.areEqual(LangParser.toAST('@spec(mod, {Int, Int}, Float)'),
    ['at_spec'.atom(), [], [['mod'.atom(), [], 'nil'.atom()], [['Int'.atom(), [], 'nil'.atom()], ['Int'.atom(), [], 'nil'.atom()]], ['Float'.atom(), [], 'nil'.atom()]]]);
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
      new ObjectMap<Dynamic, Dynamic>()
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
    var specBlock: Array<Dynamic> = ['at_spec'.atom(),[],[['order'.atom(),[],'nil'.atom()],[['String'.atom(),[],'nil'.atom()],['String'.atom(),[],'nil'.atom()]],['Dynamic'.atom(),[],'nil'.atom()]]];
    var orderBody: Array<Dynamic> = [['inject'.atom(),[],[['Ellie'.atom(),[],'nil'.atom()],'bear'.atom()]]];
    var orderBlock: Array<Dynamic> = ['def'.atom(),[],[['order'.atom(),[],[['ellie'.atom(),[],'nil'.atom()],['bear'.atom(),[],'nil'.atom()]]],{ __block__: orderBody }]];
    var helloBlock: Array<Dynamic> = ['def'.atom(),[],[['hello'.atom(),[],[['a'.atom(),[],'nil'.atom()]]],{ __block__: ["hello world"] }]];
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
    Assert.areEqual(LangParser.toAST("a=b"), ['='.atom(), [], [['a'.atom(), [] , 'nil'.atom()], ['b'.atom(), [], 'nil'.atom()]]]);
    Assert.areEqual(LangParser.toAST("a = 1"), ['='.atom(), [], [['a'.atom(), [] , 'nil'.atom()], 1]]);
  }

  public static function shouldParseGreaterThanOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("a>b"), ['>'.atom(), [], [['a'.atom(), [] , 'nil'.atom()], ['b'.atom(), [], 'nil'.atom()]]]);
    Assert.areEqual(LangParser.toAST("a > 1"), ['>'.atom(), [], [['a'.atom(), [] , 'nil'.atom()], 1]]);
  }

  public static function shouldParseLessThanOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("a<b"), ['<'.atom(), [], [['a'.atom(), [] , 'nil'.atom()], ['b'.atom(), [], 'nil'.atom()]]]);
    Assert.areEqual(LangParser.toAST("a < 1"), ['<'.atom(), [], [['a'.atom(), [] , 'nil'.atom()], 1]]);
  }

  public static function shouldParsePlusOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc + xyz"), ['+'.atom(), [], [['abc'.atom(), [] , 'nil'.atom()], ['xyz'.atom(), [], 'nil'.atom()]]]);
    Assert.areEqual(LangParser.toAST("abc + 224"), ['+'.atom(), [], [['abc'.atom(), [] , 'nil'.atom()], 224]]);
  }

  public static function shouldParseMultipleOperators(): Void {
    Assert.areEqual(LangParser.toAST("abc + xyz - 15 * 29"), ['+'.atom(),[],[['abc'.atom(),[],'nil'.atom()], ['-'.atom(),[],[['xyz'.atom(),[],'nil'.atom()], ['*'.atom(),[],[15,29]]]]]]);
  }

  public static function shouldParseMinusOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc - xyz"), ['-'.atom(), [], [['abc'.atom(), [] , 'nil'.atom()], ['xyz'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldParseMultiplyOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc * xyz"), ['*'.atom(), [], [['abc'.atom(), [] , 'nil'.atom()], ['xyz'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldParseDivideOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc / xyz"), ['/'.atom(), [], [['abc'.atom(), [] , 'nil'.atom()], ['xyz'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldParseDoubleEqualsOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc == xyz"), ['=='.atom(), [], [['abc'.atom(), [] , 'nil'.atom()], ['xyz'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldParseStabbyOperatorWithVariables(): Void {
    Assert.areEqual(LangParser.toAST("abc -> xyz"), ['->'.atom(), [], [['abc'.atom(), [] , 'nil'.atom()], ['xyz'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldHandleDotAsOperator(): Void {
    Assert.areEqual(LangParser.toAST("foo.bar"), ['.'.atom(), [], [['foo'.atom(), [] , 'nil'.atom()], ['bar'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldHandleGreaterThanOrEqualOperator(): Void {
    Assert.areEqual(LangParser.toAST("foo >= bar"), ['>='.atom(), [], [['foo'.atom(), [] , 'nil'.atom()], ['bar'.atom(), [], 'nil'.atom()]]]);
    Assert.areEqual(LangParser.toAST("ellie>=bear"), ['>='.atom(), [], [['ellie'.atom(), [] , 'nil'.atom()], ['bear'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldHandleLessThanOrEqualOperator(): Void {
    Assert.areEqual(LangParser.toAST("foo <= bar"), ['<='.atom(), [], [['foo'.atom(), [] , 'nil'.atom()], ['bar'.atom(), [], 'nil'.atom()]]]);
    Assert.areEqual(LangParser.toAST("ellie<=bear"), ['<='.atom(), [], [['ellie'.atom(), [] , 'nil'.atom()], ['bear'.atom(), [], 'nil'.atom()]]]);
  }

  public static function shouldParseAssigningFunctionToAPattern(): Void {
    var string: String = '%{"cost" => pza} = cook(a, b + 212)';
    var cost: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    var value: Dynamic = ["pza".atom(), [], 'nil'.atom()];
    cost.set('cost', value);
    Assert.areEqual(LangParser.toAST(string),
      ['='.atom(), [], [cost, ['cook'.atom(), [], [['a'.atom(), [], 'nil'.atom()], ['+'.atom(), [], [['b'.atom(), [], 'nil'.atom()], 212]]]]]]);
  }

  public static function shouldParseDoAndEndAsAST(): Void {
    var string: String = "
      defmodule Foo do
      end
    ";
    Assert.areEqual(LangParser.toAST(string), ['defmodule'.atom(), [], [['Foo'.atom(), [], 'nil'.atom()], {__block__: []}]]);

    var string: String = "
      defmodule Foo do
        inject Ellie, :bear
      end
    ";

    var doBlock: Array<Dynamic> = ['inject'.atom(),[],[['Ellie'.atom(),[],'nil'.atom()],'bear'.atom()]];
    Assert.areEqual(LangParser.toAST(string), ['defmodule'.atom(), [], [['Foo'.atom(), [], 'nil'.atom()], {__block__: [doBlock]}]]);
  }

  public static function shouldHandleDoBlocksWithParens(): Void {
    var string: String = "
      if(a > 29) do
        inject Ellie, :bear
      end
    ";

    var doBlock: Array<Dynamic> = ['inject'.atom(),[],[['Ellie'.atom(),[],'nil'.atom()],'bear'.atom()]];
    Assert.areEqual(LangParser.toAST(string), ['if'.atom(),[],[['>'.atom(),[],[['a'.atom(),[],'nil'.atom()],29]], {__block__: [doBlock]}]]);
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
    var doIfBody: Array<Dynamic> = ['inject'.atom(),[],[['Ellie'.atom(),[],'nil'.atom()],'bear'.atom()]];
    var doDefBody: Array<Dynamic> = ['if'.atom(),[],[['>'.atom(),[],[['ellie'.atom(),[],'nil'.atom()],5]], {__block__: [doIfBody]}]];
    var doModuleBody: Array<Dynamic> = ['def'.atom(),[],[['bar'.atom(),[], []], {__block__: [doDefBody]}]];
    Assert.areEqual(LangParser.toAST(string), ['defmodule'.atom(), [], [['Foo'.atom(), [], 'nil'.atom()], {__block__: [doModuleBody]}]]);
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
    var orderBody: Array<Dynamic> = [['inject'.atom(),[],[['Ellie'.atom(),[],'nil'.atom()],'bear'.atom()]]];
    var moduleBody: Array<Dynamic> = [['at_spec'.atom(),[],[['order'.atom(),[],'nil'.atom()],[['String'.atom(),[],'nil'.atom()],['String'.atom(),[],'nil'.atom()]],['Dynamic'.atom(),[],'nil'.atom()]]],['def'.atom(),[],[['order'.atom(),[],[['ellie'.atom(),[],'nil'.atom()],['bear'.atom(),[],'nil'.atom()]]],{ __block__: orderBody }]],['def'.atom(),[],[['hello'.atom(),[],[['a'.atom(),[],'nil'.atom()]]],{ __block__: helloBody}]]];
    Assert.areEqual(LangParser.toAST(expr), ['defmodule'.atom(),[],[['Foo'.atom(),[],'nil'.atom()],{ __block__: moduleBody }]]);
  }


}