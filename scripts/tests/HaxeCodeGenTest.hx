package tests;
import lang.FunctionSpec;
import lang.FunctionClauseNotFound;
import anna_unit.Assert;
import lang.ModuleSpec;
import lang.HaxeCodeGen;
import lang.Module;
import lang.ASTParser;
import lang.LangParser;
using lang.AtomSupport;

class HaxeCodeGenTest {

  public static function setup(): Void {
    Module.stop();
    Module.start();
  }

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
    return {
      "nil".atom();
    }
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

  public static function cat_0___() {
    return {
      "nil".atom();
    }
  }

  public static function baz_0___() {
    return {
      "nil".atom();
    }
  }

  public static function bar_0___() {
    return {
      "nil".atom();
    }
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

  public static function bar_3_____(v0, v1, v2) {
    return {
      switch([v0, v1, v2]) {
        case [abc, tuv, xyz]:
          "nil".atom();
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

  public static function bar_3_Int_String_Float__Atom(v0: Int, v1: String, v2: Float): Atom {
    return {
      switch([v0, v1, v2]) {
        case [abc, tuv, xyz]:
          "nil".atom();
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
        case [{ name: name, internal_name: internal_name }, foo, 39]:
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

  public static function cat_2_Int_String__Atom(v0: Int, v1: String): Atom {
    return {
      switch([v0, v1]) {
        case [age, name]:
          bar_3_Int_String_Float__Atom(age, name, 43.1);
      }
    }
  }

  public static function bar_3_Int_String_Float__Atom(v0: Int, v1: String, v2: Float): Atom {
    return {
      switch([v0, v1, v2]) {
        case [abc, tuv, xyz]:
          "nil".atom();
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
    }, FunctionClauseNotFound);
  }

  public static function shouldCallInternalFunctionThatHasNoArgs(): Void {
    var string: String = 'defmodule Foo do
  @spec(bar, nil, Atom)
  def bar() do
  end

  @spec(cat, {Int, String}, Atom)
  def cat(age, name) do
    bar()
  end
end';

    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

  public static function cat_2_Int_String__Atom(v0: Int, v1: String): Atom {
    return {
      switch([v0, v1]) {
        case [age, name]:
          bar_0___Atom();
      }
    }
  }

  public static function bar_0___Atom(): Atom {
    return {
      "nil".atom();
    }
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.isNotNull(module);
    var genHaxe: String = HaxeCodeGen.generate(module);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }

  public static function shouldGetPossibleMatchingFunctions(): Void {
    var string: String = '
defmodule Foo do
  @spec(no_args, {}, Atom)
  def no_args() do
    :ok
  end

  @spec(with_args, {String, Int}, Atom)
  def with_args(name, age) do
    :ok
  end

  @spec(with_args, {Int, String}, Atom)
  def with_args(age, name) do
    :ok
  end

  @spec(with_args, {String, Int, Float}, Atom)
  def with_args(name, age, weight) do
    :ok
  end

  @spec(bar, {String, Float}, Atom)
  def bar(name, cat_age) do
    :ok
  end

  @spec(cat, {Int, String}, Atom)
  def cat(age, name) do
    bar(name, calc_age(name, get_cat_age(age)))
  end

  @spec(get_cat_age, {Int}, Float)
  def get_cat_age(age) do
    age / 3
  end

  @spec(calc_age, {String, Float}, Float)
  def calc_age(name, age) do
    age
  end
end';
    ASTParser.parse(LangParser.toAST(string));
    var module: ModuleSpec = Module.getModule('Foo'.atom());
    var required_return: Atom = 'Atom'.atom();

    var ast: Array<Dynamic> = LangParser.toAST('no_args()');
    var var_name: Atom = ast[0];
    var args: Array<Dynamic> = ast[2];
    var type_scope: Map<Atom, Atom> = ['nil'.atom() => 'Atom'.atom()];

    var possible: Array<FunctionSpec> = HaxeCodeGen.get_matching_functions(module, var_name, args, required_return, type_scope);
    Assert.areEqual(possible.length, 1);
    Assert.areEqual(possible[0].internal_name, 'no_args_0___Atom');

    var ast: Array<Dynamic> = LangParser.toAST('with_args("foo", 8934)');
    var var_name: Atom = ast[0];
    var args: Array<Dynamic> = ast[2];
    var type_scope: Map<Atom, Atom> = ['nil'.atom() => 'Atom'.atom()];
    var possible: Array<FunctionSpec> = HaxeCodeGen.get_matching_functions(module, var_name, args, required_return, type_scope);
    Assert.areEqual(possible.length, 1);
    Assert.areEqual(possible[0].internal_name, 'with_args_2_String_Int__Atom');

    var ast: Array<Dynamic> = LangParser.toAST('with_args(name, 8934)');
    var var_name: Atom = ast[0];
    var args: Array<Dynamic> = ast[2];
    var type_scope: Map<Atom, Atom> = ['name'.atom() => 'String'.atom()];
    var possible: Array<FunctionSpec> = HaxeCodeGen.get_matching_functions(module, var_name, args, required_return, type_scope);
    Assert.areEqual(possible.length, 1);
    Assert.areEqual(possible[0].internal_name, 'with_args_2_String_Int__Atom');

    var ast: Array<Dynamic> = LangParser.toAST('with_args(5697, name)');
    var var_name: Atom = ast[0];
    var args: Array<Dynamic> = ast[2];
    var type_scope: Map<Atom, Atom> = ['name'.atom() => 'String'.atom()];
    var possible: Array<FunctionSpec> = HaxeCodeGen.get_matching_functions(module, var_name, args, required_return, type_scope);
    Assert.areEqual(possible.length, 1);
    Assert.areEqual(possible[0].internal_name, 'with_args_2_Int_String__Atom');

    var ast: Array<Dynamic> = LangParser.toAST('with_args(name, age, weight)');
    var var_name: Atom = ast[0];
    var args: Array<Dynamic> = ast[2];
    var type_scope: Map<Atom, Atom> = ['name'.atom() => 'String'.atom(), 'age'.atom() => 'Int'.atom(), 'weight'.atom() => 'Float'.atom()];
    var possible: Array<FunctionSpec> = HaxeCodeGen.get_matching_functions(module, var_name, args, required_return, type_scope);
    Assert.areEqual(possible.length, 1);
    Assert.areEqual(possible[0].internal_name, 'with_args_3_String_Int_Float__Atom');

    var ast: Array<Dynamic> = LangParser.toAST('with_args(name, age, weight, 392)');
    var var_name: Atom = ast[0];
    var args: Array<Dynamic> = ast[2];
    var type_scope: Map<Atom, Atom> = ['name'.atom() => 'String'.atom(), 'age'.atom() => 'Int'.atom(), 'weight'.atom() => 'Float'.atom()];
    var possible: Array<FunctionSpec> = HaxeCodeGen.get_matching_functions(module, var_name, args, required_return, type_scope);
    Assert.areEqual(possible.length, 0);

    var ast: Array<Dynamic> = LangParser.toAST('with_args(name, 19, get_cat_age(42))');
    var var_name: Atom = ast[0];
    var args: Array<Dynamic> = ast[2];
    var type_scope: Map<Atom, Atom> = ['name'.atom() => 'String'.atom(), 'age'.atom() => 'Int'.atom(), 'weight'.atom() => 'Float'.atom()];
    var possible: Array<FunctionSpec> = HaxeCodeGen.get_matching_functions(module, var_name, args, required_return, type_scope);
    Assert.areEqual(possible.length, 1);
    Assert.areEqual(possible[0].internal_name, 'with_args_3_String_Int_Float__Atom');

    var ast: Array<Dynamic> = LangParser.toAST('bar(name, calc_age(name, get_cat_age(age)))');
    var var_name: Atom = ast[0];
    var args: Array<Dynamic> = ast[2];
    var type_scope: Map<Atom, Atom> = ['name'.atom() => 'String'.atom(), 'age'.atom() => 'Int'.atom(), 'weight'.atom() => 'Float'.atom()];
    var possible: Array<FunctionSpec> = HaxeCodeGen.get_matching_functions(module, var_name, args, required_return, type_scope);
    Assert.areEqual(possible.length, 1);
    Assert.areEqual(possible[0].internal_name, 'bar_2_String_Float__Atom');
  }

  public static function shouldHandleNestedFunctionCalls(): Void {
    var string: String = '
defmodule Foo do
  @spec(bar, {String, Float}, Atom)
  def bar(name, cat_age) do
  end

  @spec(cat, {Int, String}, Atom)
  def cat(age, name) do
    bar(name, calc_age(name, get_cat_age(age)))
  end

  @spec(get_cat_age, {Int}, Float)
  def get_cat_age(age) do
    age
  end

  @spec(calc_age, {String, Float}, Float)
  def calc_age(name, age) do
    age
  end
end';

    var haxeCode: String = 'package ;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class Foo {

  public static function cat_2_Int_String__Atom(v0: Int, v1: String): Atom {
    return {
      switch([v0, v1]) {
        case [age, name]:
          bar_2_String_Float__Atom(name, calc_age_2_String_Float__Float(name, get_cat_age_1_Int__Float(age)));
      }
    }
  }

  public static function bar_2_String_Float__Atom(v0: String, v1: Float): Atom {
    return {
      switch([v0, v1]) {
        case [name, cat_age]:
          "nil".atom();
      }
    }
  }

  public static function calc_age_2_String_Float__Float(v0: String, v1: Float): Float {
    return {
      switch([v0, v1]) {
        case [name, age]:
          age;
      }
    }
  }

  public static function get_cat_age_1_Int__Float(v0: Int): Float {
    return {
      switch([v0]) {
        case [age]:
          age;
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