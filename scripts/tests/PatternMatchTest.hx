package tests;

import haxe.Timer;
import util.TimeUtil;
import lang.macros.PatternMatch;
import lang.UnableToMatchException;
import anna_unit.Assert;
import lang.EitherSupport;
import lang.AtomSupport;
using lang.AtomSupport;

@:build(Macros.build())
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
}