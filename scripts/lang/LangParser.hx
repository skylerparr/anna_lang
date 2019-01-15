package lang;

import lang.LangParser.ParsingState;
import compiler.CodeGen;
using lang.AtomSupport;
using StringTools;

enum ParsingState {
  NONE;
  VAL;
  ARG;
}

typedef ParseVal = {
  retVal: AST,
  index: Int,
  line: Int,
  state: ParsingState,
  body: String
}

typedef AST = {
  val: Dynamic,
  line: Int,
  args: Array<AST>
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
  private static inline var NEWLINE: String = '\n';
  private static inline var COMMA: String = ',';
  private static inline var COLON: String = ':';
  private static inline var OPEN_PAREN: String = '(';
  private static inline var CLOSE_PAREN: String = ')';

  public static function toAST(body: String): AST {
    body += '\n';
    var parseObj: ParseVal = {retVal: {val: '', args: [], line: 0}, index: 0, line: 1, state: ParsingState.NONE, body: body};

    parseAst(parseObj);

    return parseObj.retVal;
  }

  private static function parseAst(parseObj: ParseVal): Void {
    var val: String = '';

    while(parseObj.index < parseObj.body.length) {
      var char: String = parseObj.body.charAt(parseObj.index);
      switch([parseObj.state, char]) {
        case [ParsingState.NONE, SPACE]:
        case [ParsingState.NONE, NEWLINE]:
        case [ParsingState.NONE, COMMA]:
          //throw parsing exception
        case [ParsingState.NONE, COLON]:
          var parseArg: ParseVal = {retVal: {val: '', args: [], line: 1}, index: parseObj.index + 1, line: parseObj.line, state: ParsingState.NONE, body: parseObj.body};
          parseAst(parseArg);
          if(parseArg.retVal.val != '') {
            parseObj.retVal.val = cast(parseArg.retVal.val + "", String).atom();
            parseObj.index = parseArg.index;
            parseObj.retVal.line = parseArg.line;
          }
        case [ParsingState.NONE, OPEN_PAREN]:
          //could be grouping
        case [ParsingState.NONE, CLOSE_PAREN]:
          //throw parsing exception
        case [ParsingState.NONE, c]:
          val += char;
          parseObj.state = ParsingState.VAL;
        case [ParsingState.VAL, SPACE]:
          parseObj.retVal.val = val;
          parseObj.retVal.line = parseObj.line;
          val = '';
          parseObj.state = ParsingState.ARG;
          var parseArg: ParseVal = {retVal: {val: '', args: [], line: 1}, index: parseObj.index + 1, line: parseObj.line, state: ParsingState.NONE, body: parseObj.body};
          parseAst(parseArg);
          if(parseArg.retVal.val != '') {
            parseObj.retVal.args.push(parseArg.retVal);
            parseObj.index = parseArg.index;
          }
        case [ParsingState.VAL, NEWLINE]:
          parseObj.retVal.val = val;
          parseObj.retVal.line = parseObj.line;
          val = '';
          parseObj.state = ParsingState.NONE;
        case [ParsingState.VAL, COMMA]:
          parseObj.retVal.val = val;
          parseObj.index--; //don't remove the comma
          break;
        case [ParsingState.VAL, COLON]:
        case [ParsingState.VAL, OPEN_PAREN]:
          parseObj.retVal.val = val;
          parseObj.retVal.line = parseObj.line;
          val = '';
          parseObj.state = ParsingState.ARG;
          var parseArg: ParseVal = {retVal: {val: '', args: [], line: 1}, index: parseObj.index + 1, line: parseObj.line, state: ParsingState.NONE, body: parseObj.body};
          parseAst(parseArg);
          if(parseArg.retVal.val != '') {
            parseObj.retVal.args.push(parseArg.retVal);
            parseObj.index = parseArg.index;
          }
        case [ParsingState.VAL, CLOSE_PAREN]:
          //throw parsing error
        case [ParsingState.VAL, _]:
          val += char;
        case [ParsingState.ARG, SPACE]:
        case [ParsingState.ARG, NEWLINE]:
        case [ParsingState.ARG, COMMA]:
          var parseArg: ParseVal = {retVal: {val: '', args: [], line: 1}, index: parseObj.index + 1, line: parseObj.line, state: ParsingState.NONE, body: parseObj.body};
          parseAst(parseArg);
          if(parseArg.retVal.val != '') {
            parseObj.retVal.args.push(parseArg.retVal);
            parseObj.index = parseArg.index;
          }
        case [ParsingState.ARG, COLON]:
        case [ParsingState.ARG, OPEN_PAREN]:
          continue;
        case [ParsingState.ARG, CLOSE_PAREN]:
        case [ParsingState.ARG, _]:
          val += char;
        case _:
      }
      parseObj.index++;
    }
  }

}