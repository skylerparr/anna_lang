package tests;

import lang.FieldSpec;
import lang.DefinedTypes;
import lang.TypeSpec;
import lang.FunctionSpec;
import lang.ModuleSpec;
import lang.ASTParser;
import anna_unit.Assert;
import lang.LangParser;
import lang.Module;
using lang.AtomSupport;
class ASTParserTest {

  public static function setup(): Void {
    Module.stop();
    Module.start();

    DefinedTypes.stop();
    DefinedTypes.start();
  }

  public static function shouldConvertStringASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('"foo"')), '"foo"');
  }

  public static function shouldConvertEscapedStringASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('"foo\\"s"')), '"foo"s"');
  }

  public static function shouldConvertNumberASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('3412')), '3412');
  }

  public static function shouldConvertFloatingPointNumberASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('34.12')), '34.12');
  }

  public static function shouldConvertAtomASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST(':pretty')), 'AtomSupport.atom("pretty")');
  }

  public static function shouldConvertArrayASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('{}')), '[]');
  }

  public static function shouldConvertArrayWithValuesToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('{2,  :foo, "house", 292}')), '[2, AtomSupport.atom("foo"), "house", 292]');
  }

  public static function shouldConvertHashASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('%{}')), '[]');
  }

  public static function shouldConvertHashWithValuesASTToHaxe(): Void {
    Assert.anyEqual(ASTParser.parse(LangParser.toAST('%{"foo" => :bar, "car" => {}}')), ['[ foo => "bar".atom(), car => [] ]', '[ car => [], foo => "bar".atom() ]']);
  }

  public static function shouldConvertVariableToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('foobee')), 'foobee');
  }

  public static function shouldConvertFunctionCallASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('foo()')), 'foo()');
  }

  public static function shouldConvertFunctionCallWithArgsFromASTToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('foo(1, :two, three)')), 'foo(1, AtomSupport.atom("two"), three)');
  }

  public static function shouldParseFunctionWithNestedFunctionCallsAndDataStructuresToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST(
      'm(3, b(1, 2), ellie({:foo}), qtip(nozy(%{"bar" => {:cat}})))')),
    'm(3, b(1, 2), ellie([AtomSupport.atom("foo")]), qtip(nozy(["bar" => AtomSupport.atom("nil")])))');
  }

  public static function shouldConvertMultipleStatementsToHaxe(): Void {
    Assert.areEqual(ASTParser.parse(LangParser.toAST('
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
    %{"internal_name" => foo}')),
    'foo("bar", 1, 2, AtomSupport.atom("three"))
AtomSupport.atom("hash")
soo("baz", 3, 4, AtomSupport.atom("five"))
"hello world"
324
[]
coo("cat", 5, 6, AtomSupport.atom("seven"))
rem(a, b)
cook(a, +(b, 212))
+(a, b)
cost
["internal_name" => AtomSupport.atom("nil")]');
  }

  public static function shouldStoreModuleSpecInTheModuleModule(): Void {
    var string: String = 'defmodule Foo do end';
    ASTParser.parse(LangParser.toAST(string));

    Assert.isNotNull(Module.getModule('Foo'.atom()));
  }

  public static function shouldStoreModuleFunctionsInTheModuleSpec(): Void {
    var string: String = 'defmodule Foo do
      def bar() do
      end

      def cat() do
      end
    end';
    ASTParser.parse(LangParser.toAST(string));

    var moduleSpec: ModuleSpec = Module.getModule('Foo'.atom());
    var functions: Array<FunctionSpec> = moduleSpec.functions;
    Assert.areEqual(functions.length, 2);
    Assert.areEqual(functions[0].name, 'bar'.atom());
    Assert.areEqual(functions[1].name, 'cat'.atom());
  }

  public static function shouldStoreFunctionSpecWithSignatureReturnTypeAndBody(): Void {
    var string: String = 'defmodule Foo do
      @spec(bar, {String, Int}, Atom)
      def bar(abc, hij) do
        call_foo()
      end

      def cat(tuv, xyz) do
      end

      @spec(baz, nil, Atom)
      def baz() do
      end
    end';
    ASTParser.parse(LangParser.toAST(string));

    var moduleSpec: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.areEqual(moduleSpec.functions.length, 3);
    var fun1: FunctionSpec = moduleSpec.functions[0];
    var fun2: FunctionSpec = moduleSpec.functions[1];
    var fun3: FunctionSpec = moduleSpec.functions[2];

    Assert.areEqual(fun1.name, 'bar'.atom());
    Assert.areEqual(fun2.name, 'cat'.atom());
    Assert.areEqual(fun3.name, 'baz'.atom());

    Assert.areEqual(fun1.signature, [['abc'.atom(), 'String'.atom()], ['hij'.atom(), 'Int'.atom()]]);
    Assert.areEqual(fun2.signature, [['tuv'.atom(), 'nil'.atom()], ['xyz'.atom(), 'nil'.atom()]]);
    Assert.areEqual(fun3.signature, []);

    Assert.areEqual(fun1.return_type, 'Atom'.atom());
    Assert.areEqual(fun2.return_type, 'nil'.atom());
    Assert.areEqual(fun3.return_type, 'Atom'.atom());

    Assert.areEqual(fun1.body, [["call_foo".atom(),[],[]]]);
    Assert.areEqual(fun2.body, []);
    Assert.areEqual(fun3.body, []);
  }

  public static function shouldAssignAnInternalFunctionName(): Void {
    var string: String = 'defmodule Foo do
      @spec(bar, {String, Int}, Atom)
      def bar(abc, hij) do
        call_foo()
      end

      def cat(tuv, xyz, lkj) do
      end

      @spec(baz, nil, Atom)
      def baz() do
      end
    end';
    ASTParser.parse(LangParser.toAST(string));

    var moduleSpec: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.areEqual(moduleSpec.functions.length, 3);
    var fun1: FunctionSpec = moduleSpec.functions[0];
    var fun2: FunctionSpec = moduleSpec.functions[1];
    var fun3: FunctionSpec = moduleSpec.functions[2];

    Assert.areEqual(fun1.internal_name, "bar_2_String_Int__Atom");
    Assert.areEqual(fun2.internal_name, "cat_3_____");
    Assert.areEqual(fun3.internal_name, "baz_0___Atom");
  }

  public static function shouldStoreArrayTypesWithCorrectCasing(): Void {
    var string: String = 'defmodule Foo do
      @spec(bar, {Array<Lang.FunctionSpec>}, Atom)
      def bar(abc) do
      end
    end';
    ASTParser.parse(LangParser.toAST(string));

    var moduleSpec: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.areEqual(moduleSpec.functions.length, 1);
    var fun1: FunctionSpec = moduleSpec.functions[0];

    Assert.areEqual(fun1.signature[0][1], 'Array<lang.FunctionSpec>'.atom());
    Assert.areEqual(fun1.internal_name, "bar_1_Array_lang_FunctionSpec___Atom");
  }

  public static function shouldOverloadFunction(): Void {
    var string: String = 'defmodule Foo do
      @spec(bar, {String, Int}, Atom)
      def bar(abc, hij) do
        call_foo()
      end

      def bar(tuv, xyz, lkj) do
      end

      @spec(bar, nil, Atom)
      def bar() do
      end
    end';
    ASTParser.parse(LangParser.toAST(string));

    var moduleSpec: ModuleSpec = Module.getModule('Foo'.atom());
    Assert.areEqual(moduleSpec.functions.length, 3);
    var fun1: FunctionSpec = moduleSpec.functions[0];
    var fun2: FunctionSpec = moduleSpec.functions[1];
    var fun3: FunctionSpec = moduleSpec.functions[2];

    Assert.areEqual(fun1.name, 'bar'.atom());
    Assert.areEqual(fun2.name, 'bar'.atom());
    Assert.areEqual(fun3.name, 'bar'.atom());
  }

  public static function shouldResolveModuleNames(): Void {
    var string: String = 'defmodule Foo.Bar.Cat.Baz do
    end';
    ASTParser.parse(LangParser.toAST(string));

    var moduleSpec: ModuleSpec = Module.getModule('Foo.Bar.Cat.Baz'.atom());
    Assert.isNotNull(moduleSpec);
    Assert.areEqual(moduleSpec.module_name, 'Foo.Bar.Cat.Baz'.atom());
    Assert.areEqual(moduleSpec.class_name, 'Baz'.atom());
    Assert.areEqual(moduleSpec.package_name, 'foo.bar.cat'.atom());
  }

  public static function shouldDefineCustomType(): Void {
    var string: String = '
deftype Foo.Bar.MyType do
  {:name, String}
  {:age, Int}
  {:weight, Float}
end';
    ASTParser.parse(LangParser.toAST(string));
    var typeSpec: TypeSpec = DefinedTypes.getType('Foo.Bar.MyType'.atom());
    Assert.isNotNull(typeSpec);
    Assert.areEqual(typeSpec.class_name, 'MyType'.atom());
    Assert.areEqual(typeSpec.package_name, 'foo.bar'.atom());
    Assert.areEqual(typeSpec.name, 'Foo.Bar.MyType'.atom());
    var fields: Array<FieldSpec> = typeSpec.fields;
    Assert.areEqual(fields.length, 3);
    Assert.areEqual(fields[0].name, 'name'.atom());
    Assert.areEqual(fields[0].type, 'String'.atom());
    Assert.areEqual(fields[1].name, 'age'.atom());
    Assert.areEqual(fields[1].type, 'Int'.atom());
    Assert.areEqual(fields[2].name, 'weight'.atom());
    Assert.areEqual(fields[2].type, 'Float'.atom());
  }

}