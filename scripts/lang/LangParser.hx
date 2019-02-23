package lang;

import haxe.ds.ObjectMap;

using lang.AtomSupport;
using StringTools;
using lang.ArraySupport;
using lang.MapUtil;
using TypePrinter.MapPrinter;

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
  FUNCTION_ARGS;
  LEFT_RIGHT_FUNCTION;
  DO;
  COMMENT;
  EXPRESSION_UNKNOWN;
}

enum HashState {
  NONE;
  DEFINE_KEY;
  DEFINE_VALUE;
  DEFINE_TYPE;
}

@:build(macros.ScriptMacros.script())
class LangParser {

  public static var builtinAliases: Map<String, String> = {
    builtinAliases = new Map<String, String>();
    builtinAliases.set('+', 'Anna.add');
    builtinAliases.set('-', 'Anna.subtract');
    builtinAliases.set('*', 'Anna.multiply');
    builtinAliases.set('/', 'Anna.divide');
    builtinAliases.set('.', 'resolveScope');
    builtinAliases;
  };

  public static inline var SPACE: String = ' ';
  public static inline var SINGLE_QUOTE: String = "'";
  public static inline var DOUBLE_QUOTE: String = '"';
  public static inline var NEWLINE: String = '\n';
  public static inline var COMMA: String = ',';
  public static inline var COLON: String = ':';
  public static inline var OPEN_PAREN: String = '(';
  public static inline var CLOSE_PAREN: String = ')';
  public static inline var OPEN_BRACKET: String = '[';
  public static inline var CLOSE_BRACKET: String = ']';
  public static inline var OPEN_BRACE: String = '{';
  public static inline var CLOSE_BRACE: String = '}';
  public static inline var BACK_SLASH: String = "\\";
  public static inline var PLUS: String = "+";
  public static inline var MINUS: String = "-";
  public static inline var MULTIPLY: String = "*";
  public static inline var DIVIDE: String = "/";
  public static inline var PERCENT: String = "%";
  public static inline var EQUALS: String = "=";
  public static inline var GREATER_THAN: String = ">";
  public static inline var LESS_THAN: String = "<";
  public static inline var PIPE: String = "|";
  public static inline var PERIOD: String = ".";
  public static inline var AT: String = "@";
  public static inline var HASH: String = "#";
  public static inline var AMPHERSAND: String = "&";
  public static inline var CARET: String = "^";
  public static inline var DO: String = "do";
  public static inline var END: String = "end";

  private static var NUMBER: EReg = ~/[0-9]|\./;
  private static var CHAR: EReg = ~/[a-zA-Z]/;
  private static var DOT: EReg = ~/\./;
  private static var WHITESPACE: EReg = ~/\s/;
  private static var SYMBOL: EReg = ~/\W/;

  private static var leftRightOperators: Array<String> = [EQUALS, PLUS, MINUS, MULTIPLY, DIVIDE, GREATER_THAN,
    LESS_THAN, PERIOD, PIPE, AMPHERSAND];

  public static function toAST(string: String): Dynamic {
    string = sanitizeExpr(string);
    var retVal: Array<Dynamic> = parseExpr(string);
    if(retVal.length == 1) {
      return retVal[0];
    }
    return retVal;
  }

  public static function sanitizeExpr(string: String): String {
    var currentStrVal: String = '';
    var expressions: Array<String> = [];
    var state: ParsingState = ParsingState.NONE;
    var prevState: ParsingState = ParsingState.NONE;
    var parenCount: Int = 0;
    var braceCount: Int = 0;
    var doCount: Int = 0;
    var i: Int = 0;
    var operatorString: String = '';
    var functionArgsString: String = '';

    while(i < string.length) {
      var char: String = string.charAt(i);
      switch([state, NUMBER.match(char), char]) {
        case [ParsingState.NONE, true, _]:
          currentStrVal += char;
          state = ParsingState.NUMBER;
        case [ParsingState.NONE, _, DOUBLE_QUOTE]:
          currentStrVal += char;
          state = ParsingState.STRING;
        case [ParsingState.NONE, _, NEWLINE]:
          currentStrVal += char;
        case [ParsingState.NONE, _, HASH]:
          state = ParsingState.COMMENT;
        case [ParsingState.COMMENT, _, NEWLINE]:
          state = ParsingState.NONE;
        case [ParsingState.STRING, _, DOUBLE_QUOTE]:
          if(prevState == ParsingState.FUNCTION_ARGS) {
            functionArgsString += char;
          } else {
            currentStrVal += char;
            expressions.push(currentStrVal.trim());
            currentStrVal = '';
          }
          state = prevState;
          prevState = ParsingState.NONE;
        case [ParsingState.STRING, _, BACK_SLASH]:
          state = ParsingState.ESCAPE;
          if(prevState == ParsingState.FUNCTION_ARGS) {
            functionArgsString += char;
          } else {
            currentStrVal += char;
          }
        case [ParsingState.ESCAPE, _, _]:
          if(prevState == ParsingState.FUNCTION_ARGS) {
            functionArgsString += char;
          } else {
            currentStrVal += char;
          }
          state = ParsingState.STRING;
        case [ParsingState.STRING, _, _]:
          if(prevState == ParsingState.FUNCTION_ARGS) {
            functionArgsString += char;
          } else {
            currentStrVal += char;
          }
        case [ParsingState.NONE, _, COLON]:
          currentStrVal += char;
        case [ParsingState.NONE, _, PERCENT]:
          currentStrVal += char;
          state = ParsingState.HASH;
        case [ParsingState.NONE, _, COMMA]:
          currentStrVal += char;
          return currentStrVal;
        case [ParsingState.NONE | ParsingState.ARRAY, _, OPEN_BRACE]:
          currentStrVal += char;
          braceCount++;
          state = ParsingState.ARRAY;
        case [ParsingState.ARRAY, _, CLOSE_BRACE]:
          braceCount--;
          currentStrVal += char;
          if(braceCount == 0) {
            state = ParsingState.NONE;
            expressions.push(currentStrVal);
            currentStrVal = '';
          }
        case [ParsingState.ARRAY, _, SPACE]:
        case [ParsingState.ARRAY, _, _]:
          currentStrVal += char;
        case [ParsingState.HASH, _, OPEN_BRACE]:
          currentStrVal += char;
          braceCount++;
        case [ParsingState.HASH, _, CLOSE_BRACE]:
          currentStrVal += char;
          braceCount--;
          if(braceCount == 0) {
            state = ParsingState.NONE;
          }
        case [ParsingState.HASH, _, _]:
          currentStrVal += char;
        case [ParsingState.NUMBER, _, SPACE]:
          state = ParsingState.NONE;
        case [ParsingState.NUMBER, _, NEWLINE]:
          expressions.push(currentStrVal.trim());
          currentStrVal = '';
          state = ParsingState.NONE;
        case [ParsingState.NUMBER, _, PERIOD]:
          currentStrVal += char;
        case [ParsingState.NUMBER, _, COMMA]:
          currentStrVal += char;
          return currentStrVal;
        case [ParsingState.NUMBER, _, _]:
          if(SYMBOL.match(char)) {
            if(leftRightOperators.any(char)) {
              operatorString += char;
              state = ParsingState.LEFT_RIGHT_FUNCTION;
            } else {
              operatorString += char;
              state = ParsingState.NONE;
            }
          } else {
            currentStrVal += char;
          }
        case [ParsingState.FUNCTION, _, OPEN_PAREN]:
          functionArgsString = '';
          state = ParsingState.FUNCTION_ARGS;
          parenCount++;
        case [ParsingState.FUNCTION, _, NEWLINE]:
          state = ParsingState.NONE;
          var trimmed: String = currentStrVal.trim();
          if(trimmed == DO) {
            var doExp: String = expressions.pop();
            var restStr: String = string.substr(i + 1).trim();
            restStr = restStr.substr(0, restStr.length - END.length).trim();
            doExp = doExp.substr(0, doExp.length - 1) + COMMA + DO + OPEN_PAREN + restStr + CLOSE_PAREN + CLOSE_PAREN;
            return doExp;
          } else {
            expressions.push(trimmed);
          }
          currentStrVal = '';
        case [ParsingState.FUNCTION, _, SPACE]:
          state = ParsingState.EXPRESSION_UNKNOWN;
        case [ParsingState.FUNCTION, _, COMMA]:
          currentStrVal += char;
          return currentStrVal;
        case [ParsingState.FUNCTION, _, HASH]:
          state = ParsingState.COMMENT;
        case [ParsingState.FUNCTION, _, _]:
          if(leftRightOperators.any(char)) {
            operatorString += char;
            state = ParsingState.LEFT_RIGHT_FUNCTION;
          } else {
            currentStrVal += char;
          }
        case [ParsingState.EXPRESSION_UNKNOWN, _, OPEN_PAREN]:
          state = ParsingState.FUNCTION;
        case [ParsingState.EXPRESSION_UNKNOWN, _, _]:
          if(leftRightOperators.any(char)) {
            operatorString += char;
            state = ParsingState.LEFT_RIGHT_FUNCTION;
          } else if(!WHITESPACE.match(char)) {
            i--;
            parenCount++;
            state = ParsingState.FUNCTION_ARGS;
          }
        case [ParsingState.FUNCTION_ARGS, _, DOUBLE_QUOTE]:
          functionArgsString += char;
          prevState = state;
          state = ParsingState.STRING;
        case [ParsingState.FUNCTION_ARGS, _, OPEN_PAREN]:
          parenCount++;
          functionArgsString += OPEN_PAREN;
        case [ParsingState.FUNCTION_ARGS, _, CLOSE_PAREN]:
          parenCount--;
          if(parenCount == 0) {
            if(currentStrVal == DO) {
              var sanitizedArgs: String = sanitizeExpr(functionArgsString);
              currentStrVal = '${currentStrVal}${OPEN_PAREN}${sanitizedArgs}${CLOSE_PAREN}';
            } else {
              currentStrVal += parseStringArgs(functionArgsString);
            }
            expressions.push(currentStrVal.trim());
            functionArgsString = '';
            currentStrVal = '';
            state = ParsingState.NONE;
          } else {
            functionArgsString += char;
          }
        case [ParsingState.FUNCTION_ARGS, _, NEWLINE]:
          if(functionArgsString.endsWith(DO)) {
            functionArgsString += char;
            doCount++;
          } else if(functionArgsString.endsWith(END)) {
            doCount--;
            if(doCount == 0) {
              currentStrVal += parseStringArgs(functionArgsString.trim());
              expressions.push(currentStrVal.trim());
              functionArgsString = '';
              currentStrVal = '';
              parenCount = 0;
              braceCount = 0;
              doCount = 0;
              state = ParsingState.NONE;
            } else {
              functionArgsString += char;
            }
          } else {
            functionArgsString += char;
          }
        case [ParsingState.FUNCTION_ARGS, _, _]:
          functionArgsString += char;
        case [ParsingState.LEFT_RIGHT_FUNCTION, _, _]:
          if(!leftRightOperators.any(char)) {
            var rightSide: String = '';
            do {
              var rightSideChar = string.charAt(i++);
              if(rightSideChar == NEWLINE) {
                if(rightSide.trim().length == 0) {
                  continue;
                }
                break;
              }
              rightSide += rightSideChar;
            } while(i < string.length);
            var arg = sanitizeExpr(rightSide);
            if(currentStrVal.trim().length == 0) {
              currentStrVal = expressions.pop();
            }
            currentStrVal = '${operatorString}${OPEN_PAREN}${currentStrVal.trim()}${COMMA}';
            currentStrVal = currentStrVal + arg + CLOSE_PAREN;
            expressions.push(currentStrVal);
            state = ParsingState.NONE;
            currentStrVal = '';
            operatorString = '';
            functionArgsString = '';
          } else {
            operatorString += char;
          }
        case [ParsingState.NONE, _, SPACE | NEWLINE]:
          //ignore
        case [ParsingState.NONE, _, _]:
          if(leftRightOperators.any(char)) {
            operatorString += char;
            state = ParsingState.LEFT_RIGHT_FUNCTION;
          } else {
            currentStrVal += char;
            state = ParsingState.FUNCTION;
          }
        case _:
      }
      i++;
    }
    if(state == ParsingState.FUNCTION_ARGS && parenCount == 1) {
      if(functionArgsString.trim().length > 0) {
        var doIndex: Int = functionArgsString.indexOf(SPACE + DO);
        if(functionArgsString.endsWith(END) && doIndex != -1) {
          var firstArg: String = functionArgsString.substr(0, doIndex);
          firstArg = sanitizeExpr(firstArg);
          currentStrVal += OPEN_PAREN + firstArg;
          var doBlock: String = functionArgsString.substr(doIndex + 1);
          doBlock = doBlock.substr(DO.length + 1, doBlock.length - END.length - DO.length - 2);
          doBlock = doBlock.trim();
          currentStrVal += COMMA + DO + OPEN_PAREN + doBlock + CLOSE_PAREN + CLOSE_PAREN;
        } else {
          currentStrVal += parseStringArgs(functionArgsString);
        }
      } else {
        currentStrVal += CLOSE_PAREN;
      }
    }
    if(currentStrVal.length > 0) {
      expressions.push(currentStrVal.trim());
    }
    if(expressions[1].startsWith('do(') && expressions[expressions.length - 1].endsWith('end)')) {
      var left: String = expressions[0].substr(0, expressions[0].length - 1) + COMMA;
      var right: String = expressions[1].substr(0, expressions[1].length - 5) + CLOSE_PAREN;
      expressions = [left + right];
    }

    return expressions.join('\n');
  }

  public static function parseStringArgs(functionArgsString: String): String {
    var args: Array<String> = [];
    var arg: String = '';
    var isString: Bool = false;
    var openCount: Int = 0;
    var delimiter: String = null;
    var firstArg: Bool = true;
    var couldBeSpaceDelimited: Bool = false;

    var storeArg: String->Void = function(argChar: String):Void {
      if(openCount == 0) {
        var sanitizedArg: String = sanitizeExpr(arg.trim());
        if(sanitizedArg.length > 0) {
          args.push(sanitizedArg);
        }
        arg = '';
      } else {
        arg += argChar;
      }
    }

    for(i in 0...functionArgsString.length) {
      var argChar: String = functionArgsString.charAt(i);
      switch([argChar, isString, delimiter, firstArg]) {
        case [DOUBLE_QUOTE, false, _, _]:
          isString = true;
          arg += argChar;
        case [DOUBLE_QUOTE, true, _, _]:
          isString = false;
          arg += argChar;
        case [OPEN_PAREN | OPEN_BRACE | OPEN_BRACKET, false, _, _]:
          openCount++;
          arg += argChar;
        case [CLOSE_PAREN | CLOSE_BRACE | CLOSE_BRACKET, false, _, _]:
          openCount--;
          arg += argChar;
        case [_, true, _, _]:
          arg += argChar;
        case [_, false, null, true]:
          if(arg.trim().length > 0 && openCount == 0) {
            if(argChar == COMMA) {
              firstArg = false;
              delimiter = COMMA;
              storeArg('');
              continue;
            }
            if(!WHITESPACE.match(argChar)) {
              if(couldBeSpaceDelimited && (CHAR.match(argChar) || NUMBER.match(argChar))) {
                firstArg = false;
                delimiter = SPACE;
                storeArg(argChar);
                arg = argChar;
                continue;
              } else {
                arg += argChar;
              }
            } else if(arg.length > 0) {
              couldBeSpaceDelimited = true;
              continue;
            }
            if(SYMBOL.match(argChar)) {
              firstArg = false;
              delimiter = COMMA;
            }
          } else {
            arg += argChar;
          }
        case [SPACE, false, SPACE, false]:
          var trimmedStr: String = functionArgsString.trim();
          if(arg.trim() == DO && trimmedStr.endsWith(END)) {
            var doBlock: String = trimmedStr.substr(i);
            doBlock = doBlock.substr(DO.length, doBlock.length - END.length - DO.length);
            doBlock = doBlock.trim();
            args.push('do(${doBlock})');
            return '${OPEN_PAREN}${args.join(',')}${CLOSE_PAREN}';
          }
          storeArg(argChar);
        case [COMMA, false, COMMA, false]:
          storeArg(argChar);
        case _:
          arg += argChar;
      }
    }
    if(arg.length > 0) {
      storeArg('');
    }
    return '${OPEN_PAREN}${args.join(',')}${CLOSE_PAREN}';
  }

  private static inline function parseExpr(string: String): Array<Dynamic> {
    var retVal: Array<Dynamic> = [];
    var currentVal: Dynamic = 'nil'.atom();
    var currentStrVal: String = "";
    var leftStrVal: String = "";
    var operatorStrVal: String = "";
    var openCount: Int = 0;
    var state: ParsingState = ParsingState.NONE;
    var previousState: ParsingState = ParsingState.NONE;

    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      if(char == AT) {
        char = "at_";
      }
      switch([state, NUMBER.match(char), char]) {
        case [ParsingState.NONE, true, _]:
          state = ParsingState.NUMBER;
          currentStrVal += char;
        case [ParsingState.NONE, false, DOUBLE_QUOTE]:
          state = ParsingState.STRING;
        case [ParsingState.NONE, false, COLON]:
          state = ParsingState.ATOM;
        case [ParsingState.NONE, false, HASH]:
          previousState = state;
          state = ParsingState.COMMENT;
        case [ParsingState.COMMENT, _, NEWLINE]:
          state = previousState;
        case [ParsingState.COMMENT, _, _]:
          //ignore
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
          leftStrVal = currentStrVal;
          currentVal = 'nil'.atom();
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
          if(currentStrVal.substr(currentStrVal.length - 2) == DO) {
            leftStrVal = currentStrVal.substr(0, currentStrVal.length - 3) + CLOSE_PAREN;
            currentStrVal = '';
            openCount = 2;
            state = ParsingState.DO;
          } else {
            state = ParsingState.FUNCTION;
            openCount++;
            currentStrVal += char;
          }
        case [ParsingState.HASH, _, OPEN_BRACE]:
          if(openCount == 0) {
            currentStrVal += HASH;
          } else {
            currentStrVal += char;
          }
          openCount++;
        case [ParsingState.NONE, _, CLOSE_BRACE]:
          throw new ParsingException();
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
            leftStrVal = currentStrVal;
            currentVal = 'nil'.atom();
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
            currentVal = new ObjectMap();
            parseHash(currentVal, currentStrVal);
            leftStrVal = '%{${currentStrVal}}';
            retVal.push(currentVal);
            currentVal = 'nil'.atom();
            currentStrVal = "";
          } else {
            currentStrVal += char;
          }
        case [ParsingState.HASH, _, _]:
          currentStrVal += char;
        case [ParsingState.FUNCTION, _, CLOSE_PAREN | NEWLINE]:
          openCount--;
          currentStrVal += char;
          if(openCount <= 0) {
            openCount = 0;
            state = ParsingState.NONE;
            currentVal = ['nil'.atom(), [], 'nil'.atom()];
            parseFunc(currentVal, currentStrVal);
            retVal.push(currentVal);
            leftStrVal = currentStrVal;
            currentVal = 'nil'.atom();
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
          leftStrVal = currentStrVal;
          currentVal = 'nil'.atom();
          currentStrVal = "";
        case [ParsingState.FUNCTION, _, _]:
          currentStrVal += char;
        case [ParsingState.DO, _, OPEN_PAREN | OPEN_BRACKET]:
          currentStrVal += char;
          openCount++;
        case [ParsingState.DO, _, CLOSE_PAREN | CLOSE_BRACKET]:
          currentStrVal += char;
          openCount--;
          if(openCount == 0) {
            retVal = parseDoBlock(retVal, leftStrVal, currentStrVal);

            leftStrVal = '';
            currentStrVal = '';
            state = ParsingState.NONE;
          }
        case [ParsingState.DO, _, _]:
          currentStrVal += char;
        case [ParsingState.ATOM, _, _]:
          if(WHITESPACE.match(char)) {
            if(currentStrVal == '') {
              currentStrVal += char;
            }
            state = ParsingState.NONE;
            retVal.push(currentStrVal.trim().atom());
            leftStrVal = currentStrVal;
            currentVal = 'nil'.atom();
            currentStrVal = "";
          } else {
            currentStrVal += char;
          }
        case [ParsingState.STRING, _, _]:
          currentStrVal += char;
        case [ParsingState.NUMBER, true, _]:
          currentStrVal += char;
        case [ParsingState.NUMBER, _, OPEN_PAREN]:
          state = ParsingState.FUNCTION;
          currentStrVal += char;
          openCount++;
        case [ParsingState.NUMBER, _, _]:
          if(WHITESPACE.match(char)) {
            state = ParsingState.NONE;
            if(DOT.match(currentStrVal)) {
              retVal.push(Std.parseFloat(currentStrVal));
            } else {
              retVal.push(Std.parseInt(currentStrVal));
            }
            leftStrVal = currentStrVal;
            currentVal = 'nil'.atom();
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
        if(DOT.match(currentStrVal)) {
          currentVal = Std.parseFloat(currentStrVal);
        } else {
          currentVal = Std.parseInt(currentStrVal);
        }
        retVal.push(currentVal);
        currentVal = 'nil'.atom();
      case ParsingState.ATOM:
        if(currentStrVal == '') {
          throw new ParsingException();
        }
        currentVal = currentStrVal.trim().atom();
        retVal.push(currentVal);
        currentVal = 'nil'.atom();
      case ParsingState.DO:
        retVal = parseDoBlock(retVal, leftStrVal, currentStrVal);
      case ParsingState.COMMENT:
        //ignore
      case ParsingState.FUNCTION:
        currentVal = ['nil'.atom(), [], 'nil'.atom()];
        parseFunc(currentVal, currentStrVal);
        retVal.push(currentVal);
        currentVal = 'nil'.atom();
      case ParsingState.NONE:
        if(currentStrVal.length > 0) {
          currentVal = ['nil'.atom(), [], 'nil'.atom()];
          parseFunc(currentVal, currentStrVal);
          retVal.push(currentVal);
          currentVal = 'nil'.atom();
        }
      case _:
        throw new ParsingException();
    }

    if(retVal.length > 1) {
      retVal = [{__block__: retVal}];
    }

    return retVal;
  }

  private static inline function parseArray(array: Array<Dynamic>, string: String): Array<Dynamic> {
    var currentVal: String = "";
    var openCount: Int = 0;
    var state: ParsingState = ParsingState.NONE;

    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      switch([state, char]) {
        case [ParsingState.NONE, OPEN_BRACE]:
          state = ParsingState.ARRAY;
          currentVal += char;
          openCount++;
        case [ParsingState.NONE, OPEN_PAREN]:
          currentVal += char;
          openCount++;
          state = ParsingState.ARRAY;
        case [ParsingState.ARRAY, OPEN_PAREN]:
          currentVal += char;
          openCount++;
        case [ParsingState.ARRAY, CLOSE_PAREN]:
          openCount--;
          currentVal += char;
          if(openCount == 0) {
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              array.push(val[0]);
            }
            currentVal = "";
          }
        case [ParsingState.ARRAY, OPEN_BRACE]:
          currentVal += char;
          openCount++;
        case [ParsingState.ARRAY, CLOSE_BRACE]:
          currentVal += char;
          openCount--;
          if(openCount == 0) {
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              array.push(val[0]);
            }
            currentVal = "";
          }
        case [ParsingState.ARRAY, COMMA]:
          if(openCount == 0) {
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              array.push(val[0]);
            }
            currentVal = "";
          } else {
            currentVal += char;
          }
        case [ParsingState.ARRAY, _]:
          currentVal += char;
        case [ParsingState.NONE, COMMA]:
          if(openCount == 0) {
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              array.push(val[0]);
            }
            state = ParsingState.ARRAY;
            currentVal = "";
          } else {
            currentVal += char;
          }
        case [ParsingState.NONE, _]:
          currentVal += char;
        case _:
      }
    }
    if(currentVal != "") {
      if(openCount == 0) {
        var val: Array<Dynamic> = parseExpr(currentVal);
        if(val.length > 0) {
          array.push(val[0]);
        }
      }
    }
    return array;
  }

  private static inline function parseDoBlock(currentAST: Array<Dynamic>, leftStrVal: String, currentStrVal: String): Array<Dynamic> {
    var astToUpdate: Array<Dynamic>;
    if(currentAST.length == 0) {
      currentAST = parseExpr(leftStrVal);
      astToUpdate = currentAST[0][2];
    } else {
      var expr: Array<Dynamic> = parseExpr(leftStrVal);
      currentAST.push(expr[0]);
      astToUpdate = expr[0][2];
    }
    var bodyStr: String = currentStrVal.substr(0, currentStrVal.length - 2);
    bodyStr = sanitizeExpr(bodyStr);
    var body: Array<Dynamic> = parseExpr(bodyStr);
    // AST: [[{ __type__ => ATOM, value => defmodule },[],[[{ __type__ => ATOM, value => Foo },[],'nil'.atom()]]]]
    if(body.length == 0) {
      astToUpdate.push({ __block__: []});
    } else {
      if(Reflect.hasField(body[0], '__block__')) {
        astToUpdate.push(body[0]);
      } else {
        astToUpdate.push({ __block__: body});
      }
    }
    return currentAST;
  }

  private static inline function parseHash(hash: ObjectMap<Dynamic, Dynamic>, string: String): Dynamic {
    var currentVal: String = "";
    var braceCount: Int = 0;
    var key: Array<Dynamic> = null;
    var state: ParsingState = ParsingState.NONE;
    var hashState: HashState = HashState.DEFINE_TYPE;
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
            hash.set(key, val[0]);
          }
          currentVal = '';
          hashState = HashState.NONE;
        case [ParsingState.NONE, HASH, HashState.DEFINE_TYPE]:
          if(currentVal.length > 0) {
            hash.set('__TYPE__'.atom(), currentVal.atom());
          }
          hashState = HashState.NONE;
          currentVal = '';
        case [ParsingState.NONE, _, HashState.DEFINE_VALUE]:
          currentVal += char;
        case [ParsingState.NONE, SPACE, _]:
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
              hash.set(key, val[0]);
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
          hash.set(key, val[0]);
        }
      }
    }
    return hash;
  }

  private static inline function parseFunc(retVal: Array<Dynamic>, string: String): Array<Dynamic> {
    var currentVal: String = "";
    var openCount: Int = 0;
    var key: Dynamic = null;
    var state: ParsingState = ParsingState.NONE;
    var firstVal: String = "";

    for(i in 0...string.length) {
      var char: String = string.charAt(i);
      switch([state, char]) {
        case [ParsingState.NONE, OPEN_PAREN]:
          throw new ParsingException();
        case [ParsingState.FUNCTION, SPACE]:
          firstVal = currentVal;
          openCount++;
          retVal[0] = parseExpr(":" + currentVal)[0];
          state = ParsingState.ARRAY;
          currentVal = "";         
        case [ParsingState.FUNCTION, OPEN_PAREN]:
          retVal[0] = parseExpr(":" + currentVal)[0];
          state = ParsingState.ARRAY;
          openCount++;
          currentVal = "";
        case [ParsingState.FUNCTION, _]:
          currentVal += char;
        case [ParsingState.ARRAY, OPEN_PAREN | OPEN_BRACE]:
          currentVal += char;
          openCount++;
        case [ParsingState.ARRAY, CLOSE_PAREN | CLOSE_BRACE]:
          openCount--;
          if(openCount == 0) {
            retVal[2] = parseArray([], currentVal);
            state = ParsingState.NONE;
            currentVal = "";
          } else {
            currentVal += char;
          }
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
        if(currentVal.trim() != '') {
          var val: Array<Dynamic> = parseArray([], currentVal);
          if(val.length > 0) {
            retVal[2] = val;
          }
        }
      case _:
    }
    return retVal;
  }
}