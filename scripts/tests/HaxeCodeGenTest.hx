package tests;
import lang.FunctionNotFoundException;
import anna_unit.Assert;
import lang.ModuleSpec;
import lang.HaxeCodeGen;
import lang.Module;
import lang.ASTParser;
import lang.LangParser;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class HaxeCodeGenTest {

  public static function shouldGenerate1HaxeClassPerModuleDefinition(): Void {
    var string: String = 'defmodule Foo do end';
    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.areEqual(haxeCode, genHaxe);
  }

  public static function shouldGenerateHaxeWithPackage(): Void {
    var string: String = 'defmodule Foo.Bar.Cat.Baz.Cart do end';
    var haxeCode: String = 'package foo.bar.cat.baz;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Cart {

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo.Bar.Cat.Baz.Cart'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.areEqual(haxeCode, genHaxe);
  }

  public static function shouldGenerateASingleHaxeFunctionWithNoTypesOrArgs(): Void {
    var string: String = 'defmodule Foo do
  def bar() do
  end
end';

    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

  public static function bar_0___() {
    return "nil".atom();
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }

  public static function shouldGenerateMultipleFunctionsWithNoTypesOrArgs(): Void {
    var string: String = 'defmodule Foo do
  def bar() do
  end

  def cat() do
  end

  def baz() do
  end
end';

    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

  public static function bar_0___() {
    return "nil".atom();
  }

  public static function cat_0___() {
    return "nil".atom();
  }

  public static function baz_0___() {
    return "nil".atom();
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }

  public static function shouldGenerateASingleHaxeFunctionWithArgsWithNoTypes(): Void {
    var string: String = 'defmodule Foo do
  def bar(abc, tuv, xyz) do
  end
end';

    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

  public static function bar_3_____(abc, tuv, xyz) {
    return "nil".atom();
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }

  public static function shouldGenerateSingleHaxeFunctionWithTypedArgs(): Void {
    var string: String = 'defmodule Foo do
  @spec(bar, {Int, String, Float}, Atom)
  def bar(abc, tuv, xyz) do
  end
end';

    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

  public static function bar_3_Int_String_Float__Atom(abc: Int, tuv: String, xyz: Float): Atom {
    return "nil".atom();
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }

  public static function shouldCallInternalNameWhenBodyInvokesFunction(): Void {
    var string: String = 'defmodule Foo do
  @spec(bar, {Int, String, Float}, Atom)
  def bar(abc, tuv, xyz) do
  end

  @spec(cat, {Int, String}, Atom)
  def cat(age, name) do
    bar(age, name, 43.1)
  end
end';

    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

  public static function bar_3_Int_String_Float__Atom(abc: Int, tuv: String, xyz: Float): Atom {
    return "nil".atom();
  }

  public static function cat_2_Int_String__Atom(age: Int, name: String): Atom {
    return bar_3_Int_String_Float__Atom(age, name, 43.1);
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }

  public static function shouldThrowFunctionNotFoundExceptionIfNotFunctionFound(): Void {
    var string: String = 'defmodule Foo do
  @spec(bar, {Int, String, Float}, Atom)
  def bar(abc, tuv, xyz) do
  end

  @spec(cat, {Int, String}, Atom)
  def cat(age, name) do
    bar(age, 43.1)
  end
end';

    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    Assert.throwsException(function(): Void {
      HaxeCodeGen.generate(module);
    }, FunctionNotFoundException);
  }
}