package ;
import lang.macros.Macros;
import anna_unit.Assert;
@:build(lang.macros.Macros.build())
class KeywordTest {
  private static var keyword1: Keyword = @keyword{foo: "bar", baz: "cat"};
  public static function shouldCreateAKeywordVariable(): Void {
    Assert.areEqual(keyword1.toAnnaString(), '{foo: "bar", baz: "cat"}');
  }

  private static var keyword2: Keyword = @keyword{foo: @keyword{bar: "cat"}, smelly: @keyword{baz: "bird"}};
  public static function shouldCreateAKeywordWithinAKeywordVariable(): Void {
    Assert.areEqual(keyword2.toAnnaString(), '{foo: {bar: "cat"}, smelly: {baz: "bird"}}');
  }

  private static var staticKeyword: Array<Keyword> = {
    staticKeyword = [];

    staticKeyword.push(@keyword{foo: "bar"});
    staticKeyword.push(@keyword{baz: "cat"});

    staticKeyword;
  }
  public static function shouldCreateKeywordWithStaticInitializer(): Void {
    Assert.areEqual(staticKeyword, [Macros.getKeyword({foo: "bar"}), Macros.getKeyword({baz: "cat"})]);
  }

  public static function shouldCreateKeywordInFunction(): Void {
    var k: Keyword = @keyword{foo: "bar", cat: "Baz"};
    Assert.areEqual(k, Macros.getKeyword({foo: "bar", cat: "Baz"}));
  }

  public static function shouldCreateKeywordWithinKeywordInFunction(): Void {
    var k: Keyword = @keyword{foo: @keyword{bar: "cat"}, bar: @keyword{baz: "bar"}};
    Assert.areEqual(k.toAnnaString(), '{foo: {bar: "cat"}, bar: {baz: "bar"}}');
  }

  public static function shouldGetValueByKeyword():Void {
    var k: Keyword = @keyword{foo: @keyword{bar: "cat"}, bar: @keyword{baz: "bar"}};
    Assert.areEqual(Anna.toAnnaString(Keyword.get(k, @_'foo')), '{bar: "cat"}');
  }

  public static function shouldReturnNilIfKeyNotFound():Void {
    var k: Keyword = @keyword{foo: @keyword{bar: "cat"}, bar: @keyword{baz: "bar"}};
    Assert.areEqual(Keyword.get(k, @_'false'), @_'nil');
  }

  public static function shouldContainTheSameKeyMultipleTimes():Void {
    var k: Keyword = @keyword{foo: @keyword{bar: "cat"}, foo: @keyword{baz: "bar"}};
    Assert.areEqual(k.toAnnaString(), '{foo: {bar: "cat"}, foo: {baz: "bar"}}');
  }

  public static function shouldRemoveFirstItemThatMatchesKey():Void {
    var k: Keyword = @keyword{foo: @keyword{bar: "cat"}, foo: @keyword{baz: "bar"}};
    k = Keyword.remove(k, @_'foo');
    Assert.areEqual(k.toAnnaString(), '{foo: {baz: "bar"}}');
  }

  public static function shouldAddNewItem():Void {
    var k: Keyword = @keyword{foo: @keyword{bar: "cat"}};
    k = Keyword.add(k, @_'foo', @keyword{baz: "bar"});
    Assert.areEqual(k.toAnnaString(), '{foo: {bar: "cat"}, foo: {baz: "bar"}}');
  }

  public static function shouldGetAllItemsThatMatchKey():Void {
    var k: Keyword = @keyword{foo: @keyword{bar: "cat"}, foo: @keyword{baz: "bar"}};
    var got: Keyword = Keyword.getAll(k, @_'foo');
    Assert.areEqual(got.toAnnaString(), '{foo: {bar: "cat"}, foo: {baz: "bar"}}');
  }

  public static function shouldGetAllKeys():Void {
    var k: Keyword = @keyword{foo: @keyword{bar: "cat"}, foo: @keyword{baz: "bar"}, cat: "Ellie"};
    Assert.areEqual(Keyword.keys(k).toAnnaString(), '{:foo, :foo, :cat}');
  }
}
class KeywordContainer {
  public var args: Keyword;

  public function new(args: Keyword) {
    this.args = args;
  }
}

class ArrayKeywordContainer {
  public var args: Array<Keyword>;

  public function new(args: Array<Keyword>) {
    this.args = args;
  }
}
