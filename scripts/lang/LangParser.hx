package lang;

import compiler.CodeGen;
using lang.AtomSupport;
using StringTools;

enum ParsingState {
  NONE;
  NUMBER;
  STRING;
  ATOM;
  ESCAPE;
  ARRAY;
  HASH;
}

enum HashState {
  NONE;
  DEFINE_KEY;
  DEFINE_VALUE;
}

@:build(macros.ScriptMacros.script())
class LangParser {

  public static function parse(body: String): #if macro haxe.macro.Expr #else hscript.Expr #end {
    var sample: String = "
    defmodule(Foo, do:
    end

    {func: 'defmodule'.atom(), args: ['foo'.atom(), {'do'.atom(), []}], line: 0}

    defmodule('foo'.atom(), body(do:))
    ";

    var b: String = "trace('remember to assign this')";
    #if macro
    return CodeGen.parse(b);
    #else
    return CodeGen._parse(b);
    #end
  }

  private static inline var SPACE: String = ' ';
  private static inline var SINGLE_QUOTE: String = "'";
  private static inline var DOUBLE_QUOTE: String = '"';
  private static inline var NEWLINE: String = '\n';
  private static inline var COMMA: String = ',';
  private static inline var COLON: String = ':';
  private static inline var OPEN_PAREN: String = '(';
  private static inline var CLOSE_PAREN: String = ')';
  private static inline var OPEN_BRACKET: String = '[';
  private static inline var CLOSE_BRACKET: String = ']';
  private static inline var OPEN_BRACE: String = '{';
  private static inline var CLOSE_BRACE: String = '}';
  private static inline var BACK_SLASH: String = "\\";
  private static inline var PLUS: String = "+";
  private static inline var PERCENT: String = "%";
  private static inline var EQUALS: String = "=";
  private static inline var GREATER_THAN: String = ">";

  private static var CAPITALS: EReg = ~/[A-Z]/;
  private static var NUMBER: EReg = ~/[0-9]/;
  private static var INTEGER: EReg = ~/[0-9]/g;
  private static var CHAR: EReg = ~/[a-z]/;
  private static var WHITESPACE: EReg = ~/\s/;

  public static function toAST(body: String): Dynamic {
    return parseExpr(body);
  }

  private static function parseExpr(string: String): Dynamic {
    var retVal: Dynamic = null;
    var currentVal: String = "";
    var openCount: Int = 0;
    var state: ParsingState = ParsingState.NONE;
    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      switch([state, NUMBER.match(char), char]) {
        case [ParsingState.NONE, true, _]:
          state = ParsingState.NUMBER;
          currentVal += char;
        case [ParsingState.NONE, false, DOUBLE_QUOTE]:
          state = ParsingState.STRING;
        case [ParsingState.NONE, false, COLON]:
          state = ParsingState.ATOM;
        case [ParsingState.NONE, false, OPEN_BRACKET]:
          state = ParsingState.ARRAY;
          openCount++;
        case [ParsingState.NONE, false, CLOSE_BRACKET]:
          throw new ParsingException();
        case [ParsingState.NONE, false, PERCENT]:
          state = ParsingState.HASH;
        case [ParsingState.HASH, false, OPEN_BRACE]:
          if(openCount > 0) {
            currentVal += char;
          }
          openCount++;
        case [ParsingState.NONE, false, CLOSE_BRACE]:

        case [ParsingState.ARRAY, false, OPEN_BRACKET]:
          currentVal += char;
          openCount++;
        case [ParsingState.ARRAY, false, CLOSE_BRACKET]:
          openCount--;
          if(openCount == 0) {
            state = ParsingState.NONE;
            retVal = [];
            parseArray(retVal, currentVal);
            currentVal = "";
          } else {
            currentVal += char;
          }
        case [ParsingState.ARRAY, _, _]:
          currentVal += char;
        case [ParsingState.HASH, false, CLOSE_BRACE]:
          openCount--;
          if(openCount == 0) {
            state = ParsingState.NONE;
            retVal = {};
            parseHash(retVal, currentVal);
            currentVal = "";
          } else {
            currentVal += char;
          }
        case [ParsingState.HASH, _, _]:
          currentVal += char;
        case [ParsingState.ESCAPE, false, DOUBLE_QUOTE]:
          state = ParsingState.STRING;
          currentVal += char;
        case [ParsingState.STRING, false, BACK_SLASH]:
          state = ParsingState.ESCAPE;
        case [ParsingState.STRING, false, DOUBLE_QUOTE]:
          state = ParsingState.NONE;
          retVal = currentVal;
          currentVal = "";
        case [ParsingState.ATOM, _, _]:
          currentVal += char;
        case [ParsingState.STRING, _, _]:
          currentVal += char;
        case [ParsingState.NUMBER, true, _]:
          currentVal += char;
        case _:
      }
    }

    switch(state) {
      case ParsingState.NUMBER:
        retVal = Std.parseInt(currentVal);
      case ParsingState.ATOM:
        retVal = currentVal.atom();
      case ParsingState.STRING:
        throw new ParsingException();
      case ParsingState.ESCAPE:
        throw new ParsingException();
      case ParsingState.ARRAY:
        throw new ParsingException();
      case ParsingState.HASH:
      case ParsingState.NONE:

    }

    return retVal;
  }

  private static function parseArray(array: Array<Dynamic>, string: String): Array<Dynamic> {
    var currentVal: String = "";
    var openCount: Int = 0;
    var bracketCount: Int = 0;
    var state: ParsingState = ParsingState.NONE;
    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      switch([state, char]) {
        case [ParsingState.NONE, OPEN_BRACKET]:
          state = ParsingState.ARRAY;
          currentVal += char;
          bracketCount++;
        case [ParsingState.ARRAY, OPEN_BRACKET]:
          currentVal += char;
          bracketCount++;
        case [ParsingState.ARRAY, CLOSE_BRACKET]:
          currentVal += char;
          bracketCount--;
          if(bracketCount == 0) {
            var val: Dynamic = parseExpr(currentVal);
            array.push(val);
            currentVal = "";
          }
        case [ParsingState.ARRAY, _]:
          currentVal += char;
        case [ParsingState.NONE, COMMA]:
          if(bracketCount == 0) {
            var val: Dynamic = parseExpr(currentVal);
            array.push(val);
          }
          currentVal = "";
        case [ParsingState.NONE, SPACE]:
        case [ParsingState.NONE, _]:
          currentVal += char;
        case _:
      }
    }
    if(currentVal != "") {
      if(bracketCount == 0) {
        var val: Dynamic = parseExpr(currentVal);
        if(val != null) {
          array.push(val);
        }
      }
    }
    return array;
  }

  private static function parseHash(hash: Dynamic, string: String): Dynamic {
    var currentVal: String = "";
    var openCount: Int = 0;
    var braceCount: Int = 0;
    var key: Dynamic = null;
    var state: ParsingState = ParsingState.NONE;
    var hashState: HashState = HashState.NONE;
    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      switch([state, char, hashState]) {
        case [ParsingState.NONE, PERCENT, HashState.DEFINE_VALUE]:
          state = ParsingState.HASH;
          currentVal += char;
        case [ParsingState.NONE, _, HashState.NONE]:
          hashState = HashState.DEFINE_KEY;
          currentVal += char;
        case [ParsingState.NONE, EQUALS, HashState.DEFINE_KEY]:
          key = parseExpr(currentVal);
          currentVal = "";
          hashState = HashState.DEFINE_VALUE;
          state = ParsingState.NONE;
        case [ParsingState.NONE, GREATER_THAN, HashState.DEFINE_VALUE]:
        case [ParsingState.NONE, COMMA, HashState.DEFINE_VALUE]:
          var val: Dynamic = parseExpr(currentVal);
          Reflect.setField(hash, key, val);
          currentVal = "";
          hashState = HashState.NONE;
        case [ParsingState.NONE, _, HashState.DEFINE_VALUE]:
          currentVal += char;
        case [ParsingState.NONE, _, _]:
          currentVal += char;
        case [ParsingState.HASH, OPEN_BRACE, HashState.DEFINE_VALUE]:
          currentVal += char;
          braceCount++;
        case [ParsingState.HASH, CLOSE_BRACE, HashState.DEFINE_VALUE]:
          braceCount--;
          currentVal += char;
          if(braceCount == 0) {
            var val: Dynamic = parseExpr(currentVal);
            Reflect.setField(hash, key, val);
            currentVal = "";
            hashState = HashState.NONE;
          } else {
            currentVal += char;
          }
        case [ParsingState.HASH, _, _]:
          currentVal += char;
        case _:
      }
    }
    if(currentVal.trim() != "") {
      if(braceCount == 0) {
        var val: Dynamic = parseExpr(currentVal);
        if(val != null) {
          Reflect.setField(hash, key, val);
        }
      }
    }
    return hash;
  }

}