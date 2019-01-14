package lang;

import compiler.CodeGen;
using lang.AtomSupport;
using StringTools;

enum ParsingState {
  NONE;
  CHAR;
  VAL;
  CONST;
  ARG;
  VAR;
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

  private static var WHITESPACE: EReg = ~/\s/;
  private static var FUNCTION_START: String = '(';

  public static function toAST(body: String): Dynamic {
    var retVal: Dynamic = {};
    var index: Int = 0;
    var state: ParsingState = ParsingState.NONE;

    while(index <= body.length) {
      var char: String = body.charAt(index++);
      switch([state, WHITESPACE.match(char), char == FUNCTION_START]) {
        case [ParsingState.NONE, true, _]:
        case [ParsingState.NONE, false, _]:
          var functionString = extractValue(body.substr(index - 1));
          Reflect.setField(retVal, 'func', functionString.atom());
          Reflect.setField(retVal, 'line', 1);

          state = ParsingState.ARG;
          index += functionString.length;
        case [ParsingState.ARG, _, _]:
          var args = extractArgs(body.substr(index - 2));
          Reflect.setField(retVal, 'args', args);
          state = ParsingState.NONE;
          break;
        case _:
      }
    }
    if(state == ParsingState.ARG) {
      Reflect.setField(retVal, 'args', []);
    }

    return retVal;
  }

  private static function extractValue(body: String): String {
    var index: Int = 0;
    var currentString: String = '';
    var state: ParsingState = ParsingState.NONE;
    var retVal: String = '';

    while(index != body.length){
      var char: String = body.charAt(index++);
      switch([state, WHITESPACE.match(char), char == FUNCTION_START]) {
        case [ParsingState.NONE, true, _]:
        case [ParsingState.NONE, false, _]:
          state = ParsingState.CHAR;
          currentString = char;
        case [ParsingState.CHAR, false, false]:
          currentString += char;
        case [ParsingState.CHAR, false, true]:
          retVal = currentString;
          currentString = '';
          break;
        case _:
      }
    }
    if(currentString.length > 0) {
      retVal = currentString;
    }
    return retVal;
  }

  private static function extractArgs(body: String): Array<Dynamic> {
    var retVal: Array<Dynamic> = [];
    var index: Int = 0;
    var currentString: String = '';
    var state: ParsingState = ParsingState.NONE;

    while(index != body.length){
      var char: String = body.charAt(index++);
      switch([state, WHITESPACE.match(char), char == ',']) {
        case [ParsingState.NONE, true, false]:
        case [ParsingState.NONE, true, true]:
          //throw exception
        case [ParsingState.NONE, false, false]:
          state = ParsingState.VAL;
          currentString += char;
        case [ParsingState.VAL, true, false]:
          //throw exception
        case [ParsingState.VAL, false, true]:
          var arg: String = currentString;
          trace(arg);
        case _:
      }

    }
    return retVal;
  }
  
}