package tests;

import lang.ASTParser;
import anna_unit.Assert;
import lang.LangParser;
import lang.Module;
@:build(macros.ScriptMacros.script())
class ASTParserTest {

  public static function setup(): Void {
    Module.stop();
    Module.start();
  }

  public static function shouldConvertStringASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('"foo"')), '"foo"');
  }

  public static function shouldConvertEscapedStringASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('"foo\\"s"')), '"foo"s"');
  }

  public static function shouldConvertNumberASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('3412')), '3412');
  }

  public static function shouldConvertFloatingPointNumberASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('34.12')), '34.12');
  }

  public static function shouldConvertAtomASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(':pretty')), '"pretty".atom()');
  }

  public static function shouldConvertArrayASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('{}')), '[]');
  }

  public static function shouldConvertArrayWithValuesToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('{2,  :foo, "house", 292}')), '[2, "foo".atom(), "house", 292]');
  }

  public static function shouldConvertHashASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('%{}')), '[  ]');
  }

  public static function shouldConvertHashWithValuesASTToHaxe(): Void {
    Assert.anyEqual(ASTParser.toHaxe(LangParser.toAST('%{"foo" => :bar, "car" => {}}')), ['[ foo => "bar".atom(), car => [] ]', '[ car => [], foo => "bar".atom() ]']);
  }

  public static function shouldConvertVariableToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('foobee')), 'foobee');
  }

  public static function shouldConvertFunctionCallASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('foo()')), 'foo()');
  }

  public static function shouldConvertFunctionCallWithArgsFromASTToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('foo(1, :two, three)')), 'foo(1, "two".atom(), three)');
  }

  public static function shouldParseFunctionWithNestedFunctionCallsAndDataStructuresToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(
      'm(3, b(1, 2), ellie({:foo}), qtip(nozy(%{"bar" => {:cat}})))')),
    'm(3, b(1, 2), ellie(["foo".atom()]), qtip(nozy([ bar => ["cat".atom()] ])))');
  }

  public static function shouldSubstituteAliasedFunctionsWhenConvertingToHaxe(): Void {
    var aliases: Map<String, String> = new Map<String, String>();
    aliases.set('+', 'add');
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(
      '193 + 230'), aliases), 'add(193, 230)');
  }

  public static function shouldConvertMultipleStatementsToHaxe(): Void {
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST('
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
[  ]');
  }

  public static function shouldCallDefmoduleMacro(): Void {
    var string: String = "defmodule Foo do end";
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {

}'
    );
  }

  public static function shouldCallDefMacro(): Void {
    var string: String = "defmodule Foo do
      @spec(bar, nil, Dynamic)
      def bar() do
      end
    end";
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function bar(): Dynamic {

    
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
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
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
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
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
    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
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

  public static function shouldResolveDotScopeForDefModule(): Void {
    var string: String = 'defmodule Foo.Bar.Cat.Baz.Car do
    end';

    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package foo.bar.cat.baz;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Car {

}');
  }

  public static function shouldGenerateCustomType(): Void {
    var string: String = 'deftype Cat do
  {:breed, String}
  {:age, Int}
  {:name, String}
end';

    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
typedef Cat = {
breed: String,
age: Int,
name: String
}
@:build(macros.ScriptMacros.script())
class __Cat__ {}');
  }

  public static function shouldResolveLongCustomType(): Void {
    var string: String = 'deftype Foo.Bar.Baz.Car.Dig.Duke.Cat do
  {:breed, String}
  {:age, Int}
  {:name, String}
end';

    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package foo.bar.baz.car.dig.duke;
typedef Cat = {
breed: String,
age: Int,
name: String
}
@:build(macros.ScriptMacros.script())
class __Cat__ {}');
  }

  public static function shouldPrependPackageToCustomType(): Void {
    var string: String = '
    defmodule Foo do
      @spec(order, {Int, Int}, Cat.Ellie.Bear)
      def order(a, b) do
        rem(a, b)
        cook(a, b + 212)
        %{"feet" => 2, "mouth" => 1}
      end
    end';

    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function order(arg0: Int, arg1: Int): cat.ellie.__Bear__.Bear {
    var a: Int;
    var b: Int;
    switch([arg0, arg1]) {
      case _:
        a = arg0;
        b = arg1;
    }
    var v0 = rem(a, b);
    var v1 = cook(a, Anna.add(b, 212));
    return [ feet => 2, mouth => 1 ];
  }
}');
  }

  public static function shouldPrependTypeQualifierToCustomTypeIfDoesntHavePackage(): Void {
    var string: String = '
    defmodule Foo do
      @spec(order, {Int, Int}, Bear)
      def order(a, b) do
        rem(a, b)
        cook(a, b + 212)
        %{"feet" => 2, "mouth" => 1}
      end
    end';

    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function order(arg0: Int, arg1: Int): __Bear__.Bear {
    var a: Int;
    var b: Int;
    switch([arg0, arg1]) {
      case _:
        a = arg0;
        b = arg1;
    }
    var v0 = rem(a, b);
    var v1 = cook(a, Anna.add(b, 212));
    return [ feet => 2, mouth => 1 ];
  }
}');
  }

  public static function shouldAllowArgumentTypes(): Void {
    var string: String = '
    defmodule Foo do
      @spec(order, {Ellie, Int}, Bear)
      def order(a, b) do
      end
    end';

    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function order(arg0: __Ellie__.Ellie, arg1: Int): __Bear__.Bear {
    var a: __Ellie__.Ellie;
    var b: Int;
    switch([arg0, arg1]) {
      case _:
        a = arg0;
        b = arg1;
    }
    
    return "nil".atom();
  }
}');

    var string: String = '
    defmodule Foo do
      @spec(order, {Cat.Ellie.Bear, Int}, Atom)
      def order(a, b) do
      end
    end';

    Assert.areEqual(ASTParser.toHaxe(LangParser.toAST(string)),
    'package ;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class Foo {
  public static function order(arg0: cat.ellie.__Bear__.Bear, arg1: Int): Atom {
    var a: cat.ellie.__Bear__.Bear;
    var b: Int;
    switch([arg0, arg1]) {
      case _:
        a = arg0;
        b = arg1;
    }
    
    return "nil".atom();
  }
}');
  }
}