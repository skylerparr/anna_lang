package tests;

import lang.Module;
import lang.HaxeTypeCodeGen;
import anna_unit.Assert;
import lang.ASTParser;
import lang.TypeSpec;
import lang.DefinedTypes;
import lang.LangParser;

using lang.AtomSupport;

class HaxeTypeCodeGenTest {

  public static function setup(): Void {
    Module.stop();
    Module.start();

    DefinedTypes.stop();
    DefinedTypes.start();
  }

  public static function shouldGenerateACustomType(): Void {
    var string: String = '
deftype Foo.Bar.MyType do
  {:name, String}
  {:age, Int}
  {:weight, Float}
end';

    var haxeCode: String = 'package foo.bar;
import lang.CustomTypes.CustomType;
class MyType implements CustomType {

  public var name(default, never): String;
  public var age(default, never): Int;
  public var weight(default, never): Float;

  public inline function new(name: String, age: Int, weight: Float) {
    Reflect.setField(this, "name", name);
    Reflect.setField(this, "age", age);
    Reflect.setField(this, "weight", weight);
    
  }

  public function toString(): String {
    return Anna.inspect(this);
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var type: TypeSpec = DefinedTypes.getType('Foo.Bar.MyType'.atom());
    Assert.isNotNull(type);
    var genHaxe: String = HaxeTypeCodeGen.generate(type);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }

  public static function shouldGenerateAnEmptyCustomType(): Void {
    var string: String = '
deftype Foo.Bar.MyType do
end';

    var haxeCode: String = 'package foo.bar;
import lang.CustomTypes.CustomType;
class MyType implements CustomType {


  public inline function new() {
    
  }

  public function toString(): String {
    return Anna.inspect(this);
  }

}';
    ASTParser.parse(LangParser.toAST(string));
    var type: TypeSpec = DefinedTypes.getType('Foo.Bar.MyType'.atom());
    Assert.isNotNull(type);
    var genHaxe: String = HaxeTypeCodeGen.generate(type);

    Assert.stringsAreEqual(haxeCode, genHaxe);
  }
}