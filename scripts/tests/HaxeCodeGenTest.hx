package tests;
import anna_unit.Assert;
import lang.ModuleSpec;
import lang.HaxeCodeGen;
import lang.Module;
import lang.ASTParser;
import lang.LangParser;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class HaxeCodeGenTest {

//  public static function shouldGenerate1HaxeClassPerModuleDefinition(): Void {
//    var string: String = 'defmodule Foo do end';
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.areEqual(haxeCode, genHaxe);
//  }
//
//  public static function shouldGenerateHaxeWithPackage(): Void {
//    var string: String = 'defmodule Foo.Bar.Cat.Baz.Cart do end';
//    var haxeCode: String = 'package foo.bar.cat.baz;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Cart {
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo.Bar.Cat.Baz.Cart'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.areEqual(haxeCode, genHaxe);
//  }

//  public static function shouldGenerateASingleHaxeFunctionWithNoTypesOrArgs(): Void {
//    var string: String = 'defmodule Foo do
//  def bar() do
//  end
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_0___() {
//    return {
//      "nil".atom();
//    }
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }

//  public static function shouldGenerateMultipleFunctionsWithNoTypesOrArgs(): Void {
//    var string: String = 'defmodule Foo do
//  def bar() do
//  end
//
//  def cat() do
//  end
//
//  def baz() do
//  end
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_0___() {
//    return {
//      "nil".atom();
//    }
//  }
//
//  public static function cat_0___() {
//    return {
//      "nil".atom();
//    }
//  }
//
//  public static function baz_0___() {
//    return {
//      "nil".atom();
//    }
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }

//  public static function shouldGenerateASingleHaxeFunctionWithArgsWithNoTypes(): Void {
//    var string: String = 'defmodule Foo do
//  def bar(abc, tuv, xyz) do
//  end
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_3_____(abc, tuv, xyz) {
//    return {
//      "nil".atom();
//    }
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }

//  public static function shouldGenerateSingleHaxeFunctionWithTypedArgs(): Void {
//    var string: String = 'defmodule Foo do
//  @spec(bar, {Int, String, Float}, Atom)
//  def bar(abc, tuv, xyz) do
//  end
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_3_Int_String_Float__Atom(abc: Int, tuv: String, xyz: Float): Atom {
//    return {
//      "nil".atom();
//    }
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }

  public static function shouldHandleFunctionSignaturePatternMatchingWithMapsAndBasicDataTypes(): Void {
    var string: String = 'defmodule Foo do
  @spec(bar, {lang.FunctionSpec, String, Int}, Atom)
  def bar(%{:name => name, :internal_name => internal_name}, foo, 39) do
    name
  end
end';

    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

  public static function bar_3_lang_FunctionSpec_String_Int__Atom(v0: lang.FunctionSpec, v1: String, v2: Int): Atom {
    return {
      switch([v0, v1, v2]) {
        case [{ internal_name: internal_name, name: name }, foo, 39]:
          name;
      }
    }
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }

//  public static function shouldCallInternalNameWhenBodyInvokesFunction(): Void {
//    var string: String = 'defmodule Foo do
//  @spec(bar, {Int, String, Float}, Atom)
//  def bar(abc, tuv, xyz) do
//  end
//
//  @spec(cat, {Int, String}, Atom)
//  def cat(age, name) do
//    bar(age, name, 43.1)
//  end
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_3_Int_String_Float__Atom(abc: Int, tuv: String, xyz: Float): Atom {
//    return "nil".atom();
//  }
//
//  public static function cat_2_Int_String__Atom(age: Int, name: String): Atom {
//    return bar_3_Int_String_Float__Atom(age, name, 43.1);
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }
//
//  public static function shouldThrowFunctionNotFoundExceptionIfNotFunctionFound(): Void {
//    var string: String = 'defmodule Foo do
//  @spec(bar, {Int, String, Float}, Atom)
//  def bar(abc, tuv, xyz) do
//  end
//
//  @spec(cat, {Int, String}, Atom)
//  def cat(age, name) do
//    bar(age, 43.1)
//  end
//end';
//
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    Assert.throwsException(function(): Void {
//      HaxeCodeGen.generate(module);
//    }, FunctionNotFoundException);
//  }
//
//  public static function shouldCallInternalFunctionThatHasNoArgs(): Void {
//    var string: String = 'defmodule Foo do
//  @spec(bar, nil, Atom)
//  def bar() do
//  end
//
//  @spec(cat, {Int, String}, Atom)
//  def cat(age, name) do
//    bar()
//  end
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_0___Atom(): Atom {
//    return "nil".atom();
//  }
//
//  public static function cat_2_Int_String__Atom(age: Int, name: String): Atom {
//    return bar_0___Atom();
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }
//
//  public static function shouldHandleNestedFunctionCalls(): Void {
//    var string: String = 'defmodule Foo do
//  @spec(bar, {Int}, Atom)
//  def bar(cat_age) do
//  end
//
//  @spec(cat, {Int, String}, Atom)
//  def cat(age, name) do
//    bar(get_cat_age(age))
//  end
//
//  @spec(get_cat_age, {Int}, Int)
//  def get_cat_age(age) do
//    age
//  end
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_1_Int__Atom(cat_age: Int): Atom {
//    return "nil".atom();
//  }
//
//  public static function cat_2_Int_String__Atom(age: Int, name: String): Atom {
//    return bar_1_Int__Atom(get_cat_age_1_Int__Int(age));
//  }
//
//  public static function get_cat_age_1_Int__Int(age: Int): Int {
//    return age;
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }
//
//  public static function shouldHandleNestedFunctionCallsWithNoSpecs(): Void {
//    var string: String = 'defmodule Foo do
//  def bar(cat_age) do
//  end
//
//  def cat(age, name) do
//    bar(get_cat_age(age))
//  end
//
//  def get_cat_age(age) do
//    age
//  end
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_1___(cat_age) {
//    return "nil".atom();
//  }
//
//  public static function cat_2____(age, name) {
//    return bar_1___(get_cat_age_1___(age));
//  }
//
//  public static function get_cat_age_1___(age) {
//    return age;
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }
//
//  public static function shouldCallFunctionsFromOtherModules(): Void {
//    var string: String = 'defmodule Foo do
//  @spec(bar, {Int}, Atom)
//  def bar(cat_age) do
//  end
//
//  @spec(cat, {Int, String}, Atom)
//  def cat(age, name) do
//    bar(Foo.Cat.Bar.Baz.get_cat_age(age))
//  end
//
//end
//
//defmodule Foo.Cat.Bar.Baz do
//
//  @spec(get_cat_age, {Int}, Int)
//  def get_cat_age(age) do
//    age
//  end
//
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_1_Int__Atom(cat_age: Int): Atom {
//    return "nil".atom();
//  }
//
//  public static function cat_2_Int_String__Atom(age: Int, name: String): Atom {
//    return bar_1_Int__Atom(foo.cat.bar.Baz.get_cat_age_1_Int__Int(age));
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }
//
//  public static function shouldFigureOutWhichOverloadedFunctionToCall(): Void {
//    var string: String = 'defmodule Foo do
//  @spec(bar, {Int}, Atom)
//  def bar(cat_age) do
//  end
//
//  @spec(cat, {Int, String}, Atom)
//  def cat(age, name) do
//    bar(Foo.Cat.Bar.Baz.get_cat_age(age))
//  end
//
//end
//
//defmodule Foo.Cat.Bar.Baz do
//
//  @spec(get_cat_age, {Int}, Int)
//  def get_cat_age(age) do
//    age
//  end
//
//  @spec(get_cat_age, {Int, Int}, Int)
//  def get_cat_age(age, size) do
//    age
//  end
//
//end';
//
//    var haxeCode: String = 'package ;
//using lang.AtomSupport;
//
//@:build(macros.ScriptMacros.script())
//class Foo {
//
//  public static function bar_1_Int__Atom(cat_age: Int): Atom {
//    return "nil".atom();
//  }
//
//  public static function cat_2_Int_String__Atom(age: Int, name: String): Atom {
//    return bar_1_Int__Atom(foo.cat.bar.Baz.get_cat_age_1_Int__Int(age));
//  }
//
//}';
//    ASTParser.parse(LangParser.toAST(string));
//    var module: ModuleSpec = Module.getModule('Foo'.atom());
//    Assert.isNotNull(module);
//    var genHaxe: String = HaxeCodeGen.generate(module);
//
//    Assert.stringsAreEqual(haxeCode, genHaxe);
//  }
}