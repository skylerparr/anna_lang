package lang;

import compiler.CodeGen;
using lang.AtomSupport;
using StringTools;

enum ParsingState {
  NONE;
  NUMBER;
  STRING;
  ATOM;
  QUOATED_ATOM;
  QUOATED_ATOM_ESCAPE;
  ESCAPE;
  ARRAY;
  HASH;
  FUNCTION;
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
    var retVal: Array<Dynamic> = parseExpr(body);
    if(retVal.length == 1) {
      return retVal[0];
    }
    return retVal;
  }

  private static function parseExpr(string: String): Array<Dynamic> {
    var retVal: Array<Dynamic> = [];
    var currentVal: Dynamic = null;
    var currentStrVal: String = "";
    var openCount: Int = 0;
    var state: ParsingState = ParsingState.NONE;
    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      switch([state, NUMBER.match(char), char]) {
        case [ParsingState.NONE, true, _]:
          state = ParsingState.NUMBER;
          currentStrVal += char;
        case [ParsingState.NONE, false, DOUBLE_QUOTE]:
          state = ParsingState.STRING;
        case [ParsingState.NONE, false, COLON]:
          state = ParsingState.ATOM;
        case [ParsingState.ATOM, _, DOUBLE_QUOTE]:
          state = ParsingState.QUOATED_ATOM;
        case [ParsingState.QUOATED_ATOM, _, BACK_SLASH]:
          state = ParsingState.QUOATED_ATOM_ESCAPE;
        case [ParsingState.QUOATED_ATOM_ESCAPE, _, _]:
          currentStrVal += char;
          state = ParsingState.QUOATED_ATOM;
        case [ParsingState.QUOATED_ATOM, _, DOUBLE_QUOTE]:
          state = ParsingState.NONE;
          retVal.push(currentStrVal.atom());
          currentVal = null;
          currentStrVal = "";
        case [ParsingState.QUOATED_ATOM, _, _]:
          currentStrVal += char;
        case [ParsingState.NONE, _, OPEN_BRACE]:
          state = ParsingState.ARRAY;
          openCount++;
        case [ParsingState.NONE, _, CLOSE_BRACE]:
          throw new ParsingException();
        case [ParsingState.NONE, _, PERCENT]:
          state = ParsingState.HASH;
        case [ParsingState.FUNCTION, _, OPEN_PAREN]:
          state = ParsingState.FUNCTION;
          openCount++;
          currentStrVal += char;
        case [ParsingState.HASH, _, OPEN_BRACE]:
          if(openCount > 0) {
            currentStrVal += char;
          }
          openCount++;
        case [ParsingState.NONE, _, CLOSE_BRACE]:

        case [ParsingState.ARRAY, _, OPEN_BRACE]:
          currentStrVal += char;
          openCount++;
        case [ParsingState.ARRAY, _, CLOSE_BRACE]:
          openCount--;
          if(openCount == 0) {
            state = ParsingState.NONE;
            currentVal = [];
            parseArray(currentVal, currentStrVal);
            retVal.push(currentVal);
            currentVal = null;
            currentStrVal = "";
          } else {
            currentStrVal += char;
          }
        case [ParsingState.ARRAY, _, _]:
          currentStrVal += char;
        case [ParsingState.HASH, _, CLOSE_BRACE]:
          openCount--;
          if(openCount == 0) {
            state = ParsingState.NONE;
            currentVal = {};
            parseHash(currentVal, currentStrVal);
            retVal.push(currentVal);
            currentVal = null;
            currentStrVal = "";
          } else {
            currentStrVal += char;
          }
        case [ParsingState.HASH, _, _]:
          currentStrVal += char;
        case [ParsingState.FUNCTION, _, CLOSE_PAREN]:
          openCount--;
          currentStrVal += char;
          if(openCount == 0) {
            state = ParsingState.NONE;
            currentVal = [null, [], null];
            parseFunc(currentVal, currentStrVal);
            retVal.push(currentVal);
            currentVal = null;
            currentStrVal = "";
          }
        case [ParsingState.ESCAPE, _, DOUBLE_QUOTE]:
          state = ParsingState.STRING;
          currentStrVal += char;
        case [ParsingState.STRING, _, BACK_SLASH]:
          state = ParsingState.ESCAPE;
        case [ParsingState.STRING, _, DOUBLE_QUOTE]:
          state = ParsingState.NONE;
          currentVal = currentStrVal;
          retVal.push(currentVal);
          currentVal = null;
          currentStrVal = "";
        case [ParsingState.FUNCTION, _, _]:
          currentStrVal += char;
        case [ParsingState.ATOM, _, _]:
          if(WHITESPACE.match(char)) {
            state = ParsingState.NONE;
            retVal.push(currentStrVal.atom());
            currentVal = null;
            currentStrVal = "";
          } else {
            currentStrVal += char;
          }
        case [ParsingState.STRING, _, _]:
          currentStrVal += char;
        case [ParsingState.NUMBER, true, _]:
          currentStrVal += char;
        case [ParsingState.NUMBER, _, _]:
          if(WHITESPACE.match(char)) {
            state = ParsingState.NONE;
            retVal.push(Std.parseInt(currentStrVal));
            currentVal = null;
            currentStrVal = "";
          } else {
            currentStrVal += char;
          }
        case _:
          if(!WHITESPACE.match(char)) {
            state = ParsingState.FUNCTION;
            currentStrVal += char;
          }
      }
    }

    switch(state) {
      case ParsingState.NUMBER:
        currentVal = Std.parseInt(currentStrVal);
        retVal.push(currentVal);
        currentVal = null;
      case ParsingState.ATOM:
        if(currentStrVal == '') {
          throw new ParsingException();
        }
        currentVal = currentStrVal.trim().atom();
        retVal.push(currentVal);
        currentVal = null;
      case ParsingState.STRING:
        throw new ParsingException();
      case ParsingState.ESCAPE:
        throw new ParsingException();
      case ParsingState.ARRAY:
        throw new ParsingException();
      case ParsingState.HASH:
        throw new ParsingException();
      case ParsingState.FUNCTION:
        currentVal = [null, [], null];
        parseFunc(currentVal, currentStrVal);
        retVal.push(currentVal);
        currentVal = null;
      case ParsingState.QUOATED_ATOM:
        throw new ParsingException();
      case ParsingState.QUOATED_ATOM_ESCAPE:
        throw new ParsingException();
      case ParsingState.NONE:
        if(currentStrVal.length > 0) {
          currentVal = [null, [], null];
          parseFunc(currentVal, currentStrVal);
          retVal.push(currentVal);
          currentVal = null;
        }
    }

    return retVal;
  }

  private static function parseArray(array: Array<Dynamic>, string: String, spaceAsDelimiter: Bool = false): Array<Dynamic> {
    var currentVal: String = "";
    var bracketCount: Int = 0;
    var state: ParsingState = ParsingState.NONE;

    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      switch([state, char]) {
        case [ParsingState.NONE, OPEN_BRACE]:
          state = ParsingState.ARRAY;
          currentVal += char;
          bracketCount++;
        case [ParsingState.ARRAY, OPEN_BRACE]:
          currentVal += char;
          currentVal = OPEN_BRACE;
          bracketCount++;
        case [ParsingState.ARRAY, CLOSE_BRACE]:
          currentVal += char;
          bracketCount--;
          if(bracketCount == 0) {
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              array.push(val[0]);
            }
            currentVal = "";
          }
        case [ParsingState.ARRAY, _]:
          currentVal += char;
        case [ParsingState.NONE, COMMA]:
          if(bracketCount == 0) {
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              array.push(val[0]);
            }
          }
          currentVal = "";
        case [ParsingState.NONE, SPACE]:
          if(spaceAsDelimiter) {
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              array.push(val[0]);
            }
            currentVal = "";
          }
        case [ParsingState.NONE, _]:
          currentVal += char;
        case _:
      }
    }
    if(currentVal != "") {
      if(bracketCount == 0) {
        var val: Array<Dynamic> = parseExpr(currentVal);
        if(val.length > 0) {
          array.push(val[0]);
        }
      }
    }
    return array;
  }

  private static function parseHash(hash: Dynamic, string: String): Dynamic {
    var currentVal: String = "";
    var braceCount: Int = 0;
    var key: Array<Dynamic> = null;
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
          key = parseExpr(currentVal)[0];
          currentVal = "";
          hashState = HashState.DEFINE_VALUE;
          state = ParsingState.NONE;
        case [ParsingState.NONE, GREATER_THAN, HashState.DEFINE_VALUE]:
        case [ParsingState.NONE, COMMA, HashState.DEFINE_VALUE]:
          var val: Array<Dynamic> = parseExpr(currentVal);
          if(val.length > 0) {
            Reflect.setField(hash, cast key, val[0]);
          }
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
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              Reflect.setField(hash, cast key, val[0]);
            }
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
        var val: Array<Dynamic> = parseExpr(currentVal);
        if(val.length > 0) {
          Reflect.setField(hash, cast key, val[0]);
        }
      }
    }
    return hash;
  }

  private static function parseFunc(retVal: Array<Dynamic>, string: String): Array<Dynamic> {
    var currentVal: String = "";
    var openCount: Int = 0;
    var key: Dynamic = null;
    var state: ParsingState = ParsingState.NONE;

    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      switch([state, char]) {
        case [ParsingState.NONE, OPEN_PAREN]:
          throw new ParsingException();
        case [ParsingState.FUNCTION, SPACE]:
          retVal[0] = parseExpr(":" + currentVal)[0];
          state = ParsingState.ARRAY;
          currentVal = "";         
        case [ParsingState.FUNCTION, OPEN_PAREN]:
          retVal[0] = parseExpr(":" + currentVal)[0];
          state = ParsingState.ARRAY;
          currentVal = "";
        case [ParsingState.FUNCTION, _]:
          currentVal += char;
        case [ParsingState.ARRAY, CLOSE_PAREN]:
          retVal[2] = parseArray([], currentVal);
          state = ParsingState.NONE;
          currentVal = "";
        case [ParsingState.ARRAY, _]:
          currentVal += char;
        case _:
          if(!WHITESPACE.match(char)) {
            state = ParsingState.FUNCTION;
            currentVal += char;
          }
      }
    }
    switch([state, currentVal != ""]) {
      case [ParsingState.FUNCTION, true]:
        retVal[0] = parseExpr(":" + currentVal)[0];
      case [ParsingState.ARRAY, true]:
        retVal[2] = parseArray([], currentVal, true);
      case _:
    }
    return retVal;
  }
}