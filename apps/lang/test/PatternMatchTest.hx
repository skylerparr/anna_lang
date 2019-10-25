package ;

import Type.ValueType;
import lang.CustomType;
import lang.macros.PatternMatch;
using lang.AtomSupport;

@:build(lang.macros.Macros.build())
class PatternMatchTest {

  public static function shouldMatchStringVariableAndAssignString(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(foo, "hello world");
    @refute matched == null;
    @assert matched.get("foo") == "hello world";
  }

  public static function shouldMatchNumberVariableAndAssignNumber(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(foo, 843290);
    @refute matched == null;
    @assert matched.get("foo") == 843290;
  }

  public static function shouldMatchAtomVariableAndAssignAtom(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(foo, @_"ok");
    @refute matched == null;
    @assert matched.get("foo") == @_"ok";
  }

  public static function shouldMatchConstantString(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match("foo", "foo");
    @refute matched == null;
  }

  public static function shouldNotMatchConstantString(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match("foo", "bar");
    @assert matched == null;
  }

  public static function shouldMatchConstantInteger(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(123, 123);
    @refute matched == null;
  }

  public static function shouldNotMatchConstantInteger(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(123, 321);
    @assert matched == null;
  }

  public static function shouldMatchConstantFloat(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(123.123, 123.123);
    @refute matched == null;
  }

  public static function shouldNotMatchConstantFloat(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(123.123, 123.321);
    @assert matched == null;
  }

  public static function shouldMatchConstantAtom(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(@_"ok", @_"ok");
    @refute matched == null;
  }

  public static function shouldNotMatchConstantAtom(): Void {
    var matched: Map<String, Dynamic> = PatternMatch.match(@_"ok", @_"error");
    @assert matched == null;
  }

  public static function shouldMatchTupleVariableAndAssignTuple(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var matched: Map<String, Dynamic> = PatternMatch.match(foo, data);
    @refute matched == null;
    @assert matched.get("foo") == data;
  }

  public static function shouldMatchConstantTuple(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@_"ok", "foo", 123], data);
    @refute matched == null;
  }

  public static function shouldNotMatchConstantTuple(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@_"ok", "foo", 456], data);
    @assert matched == null;
  }

  public static function shouldNotMatchTupleAgainstString(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var match: Dynamic = "hello world";
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@_"ok", "foo", 456], match);
    @assert matched == null;
  }

  public static function shouldNotMatchTupleAgainstInteger(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var match: Dynamic = 4321;
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@_"ok", "foo", 456], match);
    @assert matched == null;
  }

  public static function shouldNotMatchTupleAgainstFloat(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var match: Dynamic = 26.26;
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@_"ok", "foo", 456], match);
    @assert matched == null;
  }

  public static function shouldNotMatchTupleAgainstAtom(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var match: Dynamic = @_"ok";
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@_"ok", "foo", 456], match);
    @assert matched == null;
  }

  public static function shouldNotMatchTuplesOfDifferentLengths(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@_"ok", "foo", 123, 456], data);
    @assert matched == null;
  }

  public static function shouldMatchTupleVars(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@_"ok", "foo", foo], data);
    @refute matched == null;
    @assert matched.get("foo") == 123;
  }

  public static function shouldMatchMultipleTupleVars(): Void {
    var data: Tuple = @tuple[@_"ok", "foo", 123];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[status, "foo", foo], data);
    @refute matched == null;
    @assert matched.get("foo") == 123;
    @assert matched.get("status") == @_"ok";

    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[status, name, foo], data);
    @refute matched == null;
    @assert matched.get("foo") == 123;
    @assert matched.get("status") == @_"ok";
    @assert matched.get("name") == "foo";
  }

  public static function shouldMatchNestedTuples(): Void {
    var data: Tuple = @tuple[@tuple[@_"ok", "good to go"], "foo", 123];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[@tuple[status, message], "foo", foo], data);
    @refute matched == null;
    @assert matched.get("foo") == 123;
    @assert matched.get("status") == @_"ok";
    @assert matched.get("message") == "good to go";

    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[status, "foo", foo], data);
    @refute matched == null;
    @assert matched.get("foo") == 123;
    @assert matched.get("status") == @tuple[@_"ok", "good to go"];
  }

  public static function shouldMatchEmptyTuples(): Void {
    var data: Tuple = @tuple[];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple[], data);
    @refute matched == null;
  }

  public static function shouldMatchEmptyList(): Void {
    var data: LList = @list[];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list[], data);
    @refute matched == null;
  }

  public static function shouldMatchSingleItemInList(): Void {
    var data: LList = @list["foo"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list["foo"], data);
    @refute matched == null;
  }

  public static function shouldAssignListToVariable(): Void {
    var data: LList = @list["foo"];
    var matched: Map<String, Dynamic> = PatternMatch.match(value, data);
    @refute matched == null;
    @assert matched.get("value") == @list["foo"];
  }

  public static function shouldNotMatchIfDifferentDataTypes(): Void {
    var data: Dynamic = @list["foo"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple["foo"], data);
    @assert matched == null;
  }

  public static function shouldNotMatchListsOfDifferentSize(): Void {
    var data: LList = @list["foo", "bar", "cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list["foo", "bar"], data);
    @assert matched == null;
    var data: LList = @list["foo", "bar", "cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list["foo", "bar", "cat", "tree"], data);
    @assert matched == null;
  }

  public static function shouldMatchSingleValue(): Void {
    var data: LList = @list["bar"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list[foo], data);
    @refute matched == null;
    @assert matched.get("foo") == "bar";
  }

  public static function shouldMatchManyValues(): Void {
    var data: LList = @list["foo", 123, @_"ok", 301.239, @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list[foo, int, atom, float, @_"cat"], data);
    @refute matched == null;
    @assert matched.get("foo") == "foo";
    @assert matched.get("int") == 123;
    @assert matched.get("atom") == @_"ok";
    @assert matched.get("float") == 301.239;
  }

  public static function shouldNotMatchIfAnyValueDoesntMatch(): Void {
    var data: LList = @list["foo", 123, @_"ok", 301.239, @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list[foo, 123, atom, 302.239, @_"cat"], data);
    @assert matched == null;
  }

  public static function shouldMatchHeadAndTail(): Void {
    var data: LList = @list["foo", 123, @_"ok", 301.239, @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list[head | tail], data);
    @refute matched == null;
    @assert matched.get("head") == "foo";
    @assert matched.get("tail") == @list[123, @_"ok", 301.239, @_"cat"];
  }

  public static function shouldPatternMatchHeadAndAssignTail(): Void {
    var data: LList = @list["foo", 123, @_"ok", 301.239, @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list["foo" | tail], data);
    @refute matched == null;
    @assert matched.get("tail") == @list[123, @_"ok", 301.239, @_"cat"];
  }

  public static function shouldMatchHeadAndPatternMatchTail(): Void {
    var data: LList = @list["foo", 123, @_"ok", 301.239, @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list[head | @list[123, @_"ok", 301.239, @_"cat"]], data);
    @refute matched == null;
    @assert matched.get("head") == "foo";
  }

  public static function shouldPatternMatchHeadAndPatternMatchTail(): Void {
    var data: LList = @list["foo", 123, @_"ok", 301.239, @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list["foo" | @list[123, @_"ok", 301.239, @_"cat"]], data);
    @refute matched == null;
  }

  public static function shouldPatternMatchHeadAndSubMatchTail(): Void {
    var data: LList = @list["foo", 123, @_"ok", 301.239, @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list["foo" | @list[123, @_"ok", float, @_"cat"]], data);
    @refute matched == null;
    @assert matched.get("float") == 301.239;
  }

  public static function shouldMatchTupleValueWithinList(): Void {
    var data: LList = @list["foo", 123, @_"ok", @tuple["1", 2, @_"three"], @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list["foo" | @list[123, @_"ok", @tuple["1", 2, number], @_"cat"]], data);
    @refute matched == null;
    @assert matched.get("number") == @_"three";
  }

  public static function shouldMatchListValueWithinTuple(): Void {
    var data: Tuple = @tuple["foo", 123, @_"ok", @list["1", 2, @_"three"], @_"cat"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@tuple["foo", 123, @_"ok", @list["1", 2, number], @_"cat"], data);
    @refute matched == null;
    @assert matched.get("number") == @_"three";
  }

  public static function shouldMatchListTailIfTheresOneElementInTheEntireList(): Void {
    var data: LList = @list["foo"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list[head | tail], data);
    @refute matched == null;
    @assert matched.get("head") == "foo";
    @assert matched.get("tail") == @list[];
  }

  public static function shouldReturnNilIfListLengthIsZero(): Void {
    var data: LList = @list[];
    var matched: Map<String, Dynamic> = PatternMatch.match(@list[head | tail], data);
    @refute matched == null;
    @assert matched.get("head") == @_'nil';
    @assert matched.get("tail") == @_'nil';
  }

  public static function shouldMatchEmptyMap(): Void {
    var data: MMap = @map[];
    var matched: Map<String, Dynamic> = PatternMatch.match(@map[], data);
    @refute matched == null;
  }

  public static function shouldAssignToVariable(): Void {
    var data: MMap = @map[@_"key" => "value"];
    var matched: Map<String, Dynamic> = PatternMatch.match(map, data);
    @refute matched == null;
    @assert data == matched.get("map");
  }

  public static function shouldNotMapMatchIfDifferentDataTypes(): Void {
    var data: Dynamic = @list[];
    var matched: Map<String, Dynamic> = PatternMatch.match(@map[], data);
    @assert matched == null;
  }

  public static function shouldMatchOnAtomKey(): Void {
    var data: MMap = @map[@_"key" => "value"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@map[@_"key" => result], data);
    @refute matched == null;
    @assert matched.get("result") == "value";
  }

  public static function shouldMatchStringKey(): Void {
    var data: MMap = @map["key" => "value"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@map["key" => result], data);
    @refute matched == null;
    @assert matched.get("result") == "value";
  }

  public static function shouldMatchStringKeyAndValue(): Void {
    var data: MMap = @map["key" => "value"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@map["key" => "value"], data);
    @refute matched == null;
  }

  public static function shouldNotMatchStringKeyAndMismatchedValue(): Void {
    var data: MMap = @map["key" => "value"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@map["key" => "foo"], data);
    @assert matched == null;
  }

  public static function shouldMatchAtomKeyAndTupleValue(): Void {
    var data: MMap = @map[@_"result" => @tuple[@_"ok", "super message"]];
    var matched: Map<String, Dynamic> = PatternMatch.match(@map[@_"result" => @tuple[@_"ok", message]], data);
    @refute matched == null;
    @assert matched.get("message") == "super message";
  }

  public static function shouldMatchIfFewerKeysThanEntireMap(): Void {
    var data: MMap = @map[@_"key1" => @tuple[@_"ok", "super message"], @_"key2" => "face"];
    var matched: Map<String, Dynamic> = PatternMatch.match(@map[@_"key1" => @tuple[@_"ok", message]], data);
    @refute matched == null;
    @assert matched.get("message") == "super message";

    var matched: Map<String, Dynamic> = PatternMatch.match(@map[@_"key2" => key2], data);
    @refute matched == null;
    @assert matched.get("key2") == "face";
  }

  public static function shouldAssignCustomType(): Void {
    var data: TestCustomType = new TestCustomType({name: "foo", age: 32});
    var matched: Map<String, Dynamic> = PatternMatch.match(customType, data);
    @refute matched == null;
    @assert matched.get("customType") == data;
  }

  public static function shouldMatchCustomTypeFields(): Void {
    var data: TestCustomType = new TestCustomType({name: "foo", age: 32});
    var matched: Map<String, Dynamic> = PatternMatch.match(TestCustomType%{name: name, age: age}, data);
    @refute matched == null;
    @assert matched.get("name") == "foo";
    @assert matched.get("age") == 32;
  }

  public static function shouldNotMatchCustomTypeFieldsIfValuesDontMatch(): Void {
    var data: TestCustomType = new TestCustomType({name: "foo", age: 32});
    var matched: Map<String, Dynamic> = PatternMatch.match(TestCustomType%{name: "bar", age: age}, data);
    @assert matched == null;
  }

  public static function shouldMatchWithMixtureOfAssignments(): Void {
    var data: TestCustomType = new TestCustomType({name: "foo", age: 32});
    var matched: Map<String, Dynamic> = PatternMatch.match(TestCustomType%{name: "foo", age: age}, data);
    @refute matched == null;
    @assert matched.get("name") == null;
    @assert matched.get("age") == 32;
  }

  public static function shouldNotMatchWithIncompatibleTypes(): Void {
    var data: TestCustomType = new TestCustomType({name: "foo", age: 32});
    var matched: Map<String, Dynamic> = PatternMatch.match(FooCustomType%{name: name, age: age}, data);
    @assert matched == null;
  }

  public static function shouldPatternMatchComplexTypesAsCustomTypeFields(): Void {
    var data: CustomTypeWithComplexTypes = new CustomTypeWithComplexTypes(
      {
        tup: @tuple[@_"ok", "success"],
        list: @list[1, "two", @_"three"],
        map: @map[@_"ok" => "more success"]
      }
    );
    var matched: Map<String, Dynamic> = PatternMatch.match(
      CustomTypeWithComplexTypes%{
        tup: @tuple[@_"ok", tupleValue],
        list: @list[1, listValue, @_"three"],
        map: @map[@_"ok" => mapValue]
      },
      data);
    @refute matched == null;
    @assert matched.get("tupleValue") == "success";
    @assert matched.get("listValue") == "two";
    @assert matched.get("mapValue") == "more success";
  }

  public static function shouldPatternMatchTheEndOfAString(): Void {
    var data: String = "hello world";
    var matched: Map<String, Dynamic> = PatternMatch.match("hello " => variable, data);
    @refute matched == null;
    @assert matched.get("variable") == "world";
  }

  public static function shouldNotPatternMatchTheEndOfAStringIfDoesntMatch(): Void {
    var data: String = "hello world";
    var matched: Map<String, Dynamic> = PatternMatch.match("foo " => variable, data);
    @assert matched == null;
  }
}

class TestCustomType implements CustomType {
  public var name: String;
  public var age: Int;

  public var variables: Map<String,String>;

  public function new(args: Dynamic) {
    name = args.name;
    age = args.age;
  }

  public function toAnnaString(): String {
    var fieldPairs: Array<String> = [];
    for(field in Reflect.fields(this)) {
      fieldPairs.push('${StringTools.replace(Anna.toAnnaString(field), '"', '')}: ${Anna.toAnnaString(Reflect.field(this, field))}');
    }
    var classType: ValueType = Type.typeof(this);
    var name: String = switch(classType) {
      case TClass(name):
        '${name}';
      case _:
        "CustomType";
    }
    return '${name}%{${fieldPairs.join(', ')}}';
  }
}

class FooCustomType implements CustomType {
  public var name: String;
  public var age: Int;
  public var variables: Map<String,String>;

  public function new(args: Dynamic) {
    name = args.name;
    age = args.age;
  }

  public function toAnnaString(): String {
    var fieldPairs: Array<String> = [];
    for(field in Reflect.fields(this)) {
      fieldPairs.push('${StringTools.replace(Anna.toAnnaString(field), '"', '')}: ${Anna.toAnnaString(Reflect.field(this, field))}');
    }
    var classType: ValueType = Type.typeof(this);
    var name: String = switch(classType) {
      case TClass(name):
        '${name}';
      case _:
        "CustomType";
    }
    return '${name}%{${fieldPairs.join(', ')}}';
  }
}

class CustomTypeWithComplexTypes implements CustomType {
  public var tup: Tuple;
  public var list: LList;
  public var map: MMap;
  public var variables: Map<String,String>;

  public function new(args: Dynamic) {
    tup = args.tup;
    list = args.list;
    map = args.map;
  }

  public function toAnnaString(): String {
    var fieldPairs: Array<String> = [];
    for(field in Reflect.fields(this)) {
      fieldPairs.push('${StringTools.replace(Anna.toAnnaString(field), '"', '')}: ${Anna.toAnnaString(Reflect.field(this, field))}');
    }
    var classType: ValueType = Type.typeof(this);
    var name: String = switch(classType) {
      case TClass(name):
        '${name}';
      case _:
        "CustomType";
    }
    return '${name}%{${fieldPairs.join(', ')}}';
  }
}