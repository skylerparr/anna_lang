package lang;

import Type.ValueType;
import compiler.CodeGen;
using lang.AtomSupport;
using StringTools;
using lang.ArraySupport;

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
}

@:build(macros.ScriptMacros.script())
class LangParser {
  private static var builtinAliases: Map<String, String> = {
    builtinAliases = new Map<String, String>();
    builtinAliases.set('+', 'Anna.add');
    builtinAliases.set('-', 'Anna.subtract');
    builtinAliases.set('*', 'Anna.multiply');
    builtinAliases.set('/', 'Anna.divide');
    builtinAliases.set('.', 'resolveScope');
    builtinAliases;
  };

  public static function parse(body: String, aliases: Map<String, String> = null): #if macro haxe.macro.Expr #else hscript.Expr #end {
    if(aliases == null) {
      aliases = new Map<String, String>();
    }
    for(alias in builtinAliases.keys()) {
      aliases.set(alias, builtinAliases.get(alias));
    }

    var ast: Dynamic = toAST(body);
    var haxeStr: String = toHaxe(ast, aliases);

    #if macro
    return CodeGen._parse(haxeStr);
    #else
    return CodeGen.parse(haxeStr);
    #end
  }

  public static function _defmodule(moduleDef: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    var moduleName: String = moduleDef[0].value;
    context.moduleName = moduleName;
    var retVal: String =
'package;
using lang.AtomSupport;
@:build(macros.ScriptMacros.script())
class ${moduleName} {';
    var moduleBody: String = toHaxe(body[0], aliases);
    return '${retVal}\n${moduleBody}\n}';
  }

  public static function _def(defDef: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    var retVal: String = null;
    var functionName: String = defDef[0].value;
    var functionArgsAST: Array<Dynamic> = defDef[2];

    var funArgs: Array<String> = [];
    for(funArg in functionArgsAST) {
      var haxeArg: String = toHaxe(funArg);
      funArgs.push(haxeArg);
    }

    var retType: String = '';
    var specs: Map<String, Dynamic> = context.specs;
    var typedArgs: Array<String> = [];
    var genericArgs: Array<String> = [];
    var spec: Dynamic = null;
    if(specs != null) {
      spec = specs.get(functionName);
      if(spec != null) {
        retType = ': ${spec[1][0].value}';
        for(i in 0...funArgs.length) {
          var type: String = spec[0][i][0].value;
          var argName: String = 'arg${i}';
          typedArgs.push('${argName}: ${type}');
          genericArgs.push(argName);
        }
      }
    }

    var funBody: Array<String> = [];
    var counter: Int = 0;
    for(expr in cast(body[0].__block__, Array<Dynamic>)) {
      if(Reflect.hasField(expr, "__block__")) {
        for(expr in cast(expr.__block__, Array<Dynamic>)) {
          counter++;
          funBody.push('var v${counter} = ${toHaxe(expr)};');
        }
      } else {
        funBody.push('var v${counter} = ${toHaxe(expr)};');
      }
    }
    var finalExpr: String = funBody.pop();
    if(finalExpr != null) {
      var regex: EReg = ~/var v[0-9].= /;
      finalExpr = 'return ${regex.replace(finalExpr, "")}';
    } else {
      finalExpr = 'return "nil".atom();';
    }

    var patternAssignment: String = "";

    if(funArgs.length > 0) {
      var patternAssignedArgs: Array<String> = [];
      var patternArgsDeclarations: Array<String> = [];
      for(i in 0...funArgs.length) {
        patternAssignedArgs.push('        ${funArgs[i]} = ${genericArgs[i]};');
        var type: String = spec[0][i][0].value;
        patternArgsDeclarations.push('    var ${funArgs[i]}: ${type};');
      }

      patternAssignment = '${patternArgsDeclarations.join('\n')}
    switch([${genericArgs.join(', ')}]) {
      case _:
${patternAssignedArgs.join('\n')}
    }';
    }

    retVal = '  public static function ${functionName}(${typedArgs.join(', ')})${retType} {
${patternAssignment}
    ${funBody.join("\n    ")}
    ${finalExpr}
  }';
    return retVal;
  }

  public static function _at_spec(specDef: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    var funcName: String = specDef[0].value;
    if(context.specs == null) {
      context.specs = new Map<String, Dynamic>();
    }
    var specs: Map<String, Dynamic> = context.specs;
    specs.set(funcName, body);
    return null;
  }

  public static function _patternMatch(patternDef: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    trace('pattern match');
    trace(patternDef);
    trace(body);
    return null;
  }

  public static function toHaxe(ast: Dynamic, aliases: Map<String, String> = null, context: Dynamic = null): String {
    if(aliases == null) {
      aliases = new Map<String, String>();
      for(alias in builtinAliases.keys()) {
        aliases.set(alias, builtinAliases.get(alias));
      }
    }
    if(context == null) {
      context = {};
    }
    var retVal: String = '';
    switch(Type.typeof(ast)) {
      case TInt | TFloat:
        retVal = ast;
      case ValueType.TClass(String):
        retVal = '"${ast}"';
      case ValueType.TClass(Array):
        var vals: Array<String> = [];
        var orig: Array<Dynamic> = cast ast;
        if(orig.length == 3) {
          switch(orig) {
            case [fun, [], null]:
              retVal = fun.value;
            case [fun, [], args]:
              var funName: String = aliases.get(fun.value);
              if(funName == null) {
                funName = fun.value;
              }
              var langParserFields: Array<String> = Type.getClassFields(LangParser);
              var macroFunc: Dynamic = null;
              for(field in langParserFields) {
                if('_${funName}' == field) {
                  macroFunc = Reflect.getProperty(LangParser, field);
                  break;
                }
              }
              if(macroFunc != null) {
                retVal = macroFunc(args.shift(), args, aliases, context);
              } else {
                var parsedArgs: Array<String> = [];
                for(arg in cast(args, Array<Dynamic>)) {
                  parsedArgs.push(toHaxe(arg, aliases, context));
                }
                retVal = '${funName}(${parsedArgs.join(", ")})';
              }
            case _:
              throw new ParsingException();
          }
        } else {
          for(val in orig) {
            vals.push(toHaxe(val, aliases, context));
          }
          retVal = '[${vals.join(", ")}]';
        }
      case ValueType.TObject:
        if(Reflect.hasField(ast, '__type__')) {
          retVal = '"${ast.value}".atom()';
        } else if(Reflect.hasField(ast, '__block__')) {
          var vals: Array<String> = [];
          var orig: Array<Dynamic> = cast(Reflect.field(ast, '__block__'));
          for(val in orig) {
            var haxeString: String = toHaxe(val, aliases, context);
            if(haxeString != null) {
              vals.push(haxeString);
            }
          }
          retVal = vals.join("\n");
        } else {
          var vals: Array<String> = [];
          var fields: Array<String> = Reflect.fields(ast);
          for(field in fields) {
            vals.push('${toHaxe(field, aliases, context)}: ${toHaxe(Reflect.field(ast, field), aliases, context)}');
          }
          retVal = '{${vals.join(", ")}}';
        }
      case _:
        throw new ParsingException();
    }
    return retVal;
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
  private static inline var MINUS: String = "-";
  private static inline var MULTIPLY: String = "*";
  private static inline var DIVIDE: String = "/";
  private static inline var PERCENT: String = "%";
  private static inline var EQUALS: String = "=";
  private static inline var GREATER_THAN: String = ">";
  private static inline var LESS_THAN: String = "<";
  private static inline var PIPE: String = "|";
  private static inline var PERIOD: String = ".";
  private static inline var AT: String = "@";
  private static inline var HASH: String = "#";
  private static inline var AMPHERSAND: String = "&";
  private static inline var CARET: String = "^";
  private static inline var DO: String = "do";
  private static inline var END: String = "end";

  private static var NUMBER: EReg = ~/[0-9]|\./;
  private static var CHAR: EReg = ~/[a-z][A-Z]/;
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
    var retVal: String = '';
    var state: ParsingState = ParsingState.NONE;
    var prevState: ParsingState = ParsingState.NONE;
    var parenCount: Int = 0;
    var braceCount: Int = 0;
    var i: Int = 0;
    var operatorString: String = '';

    while(i < string.length) {
      var char: String = string.charAt(i);
      switch([state, NUMBER.match(char), char, SYMBOL.match(char)]) {
        case [ParsingState.NONE, true, _, _]:
          retVal += char;
          state = ParsingState.NUMBER;
        case [ParsingState.NONE, _, DOUBLE_QUOTE, _]:
          retVal += char;
          state = ParsingState.STRING;
        case [ParsingState.STRING, _, DOUBLE_QUOTE, _]:
          retVal += char;
          state = prevState;
          prevState = ParsingState.NONE;
        case [ParsingState.STRING, _, BACK_SLASH, _]:
          state = ParsingState.ESCAPE;
        case [ParsingState.ESCAPE, _, _, _]:
          retVal += char;
          state = ParsingState.STRING;
        case [ParsingState.STRING, _, _, _]:
          retVal += char;
        case [ParsingState.NONE, _, COLON, _]:
          retVal += char;
        case [ParsingState.NONE, _, PERCENT, _]:
          retVal += char;
          state = ParsingState.HASH;
        case [ParsingState.NONE | ParsingState.ARRAY, _, OPEN_BRACE, _]:
          retVal += char;
          braceCount++;
          state = ParsingState.ARRAY;
        case [ParsingState.ARRAY, _, CLOSE_BRACE, _]:
          braceCount--;
          retVal += char;
          if(braceCount == 0) {
            state = ParsingState.NONE;
          }
        case [ParsingState.ARRAY, _, SPACE, _]:
        case [ParsingState.ARRAY, _, _, _]:
          retVal += char;
        case [ParsingState.HASH, _, OPEN_BRACE, _]:
          retVal += char;
          braceCount++;
        case [ParsingState.HASH, _, CLOSE_BRACE, _]:
          retVal += char;
          braceCount--;
          if(braceCount == 0) {
            state = ParsingState.NONE;
          }
        case [ParsingState.HASH, _, _, _]:
          retVal += char;
        case [ParsingState.NUMBER, _, SPACE | NEWLINE, _]:
          state = ParsingState.NONE;
        case [ParsingState.NUMBER, _, PERIOD, _]:
          retVal += char;
        case [ParsingState.NUMBER, _, _, true]:
          operatorString += char;
          state = ParsingState.NONE;
        case [ParsingState.NUMBER, _, _, _]:
          retVal += char;
        case [ParsingState.FUNCTION, _, OPEN_PAREN, _]:
          retVal += char;
          parenCount++;
          state = ParsingState.FUNCTION_ARGS;
        case [ParsingState.FUNCTION, _, SPACE, _]:
          state = ParsingState.EXPRESSION_UNKNOWN;
        case [ParsingState.FUNCTION, _, _, _]:
          if(leftRightOperators.any(char)) {
            operatorString += char;
            state = ParsingState.LEFT_RIGHT_FUNCTION;
          } else {
            retVal += char;
          }
        case [ParsingState.EXPRESSION_UNKNOWN, _, OPEN_PAREN, _]:
          state = ParsingState.FUNCTION;
        case [ParsingState.EXPRESSION_UNKNOWN, _, _, _]:
          if(leftRightOperators.any(char)) {
            operatorString += char;
            state = ParsingState.LEFT_RIGHT_FUNCTION;
          } else if(!WHITESPACE.match(char)) {
            retVal += '${OPEN_PAREN}${char}';
            parenCount++;
            state = ParsingState.FUNCTION_ARGS;
          }
        case [ParsingState.FUNCTION_ARGS, _, SPACE | NEWLINE, _]:
        case [ParsingState.FUNCTION_ARGS, _, DOUBLE_QUOTE, _]:
          retVal += char;
          prevState = state;
          state = ParsingState.STRING;
        case [ParsingState.FUNCTION_ARGS, _, OPEN_PAREN, _]:
          parenCount++;
          retVal += OPEN_PAREN;
        case [ParsingState.FUNCTION_ARGS, _, CLOSE_PAREN, _]:
          parenCount--;
          retVal += CLOSE_PAREN;
          if(parenCount == 0) {
            state = ParsingState.NONE;
          }
        case [ParsingState.FUNCTION_ARGS, _, _, _]:
          retVal += char;
        case [ParsingState.LEFT_RIGHT_FUNCTION, _, _, _]:
          if(!leftRightOperators.any(char)) {
            state = ParsingState.FUNCTION_ARGS;
            char = (WHITESPACE.match(char)) ? '' : char;
            retVal = '${operatorString}${OPEN_PAREN}${retVal},';
            var arg = sanitizeExpr(string.substr(i));
            retVal = retVal + arg;
            i = string.length;
            parenCount++;
          } else {
            operatorString += char;
          }
        case [ParsingState.NONE, _, SPACE | NEWLINE, _]:
        case [ParsingState.NONE, _, _, _]:
          if(leftRightOperators.any(char)) {
            operatorString += char;
            state = ParsingState.LEFT_RIGHT_FUNCTION;
          } else {
            retVal += char;
            state = ParsingState.FUNCTION;
          }
        case _:
      }
      i++;
    }
    if(state == ParsingState.FUNCTION_ARGS && parenCount == 1) {
      retVal += ')';
    }

    return retVal.trim();
  }

  private static inline function parseExpr(string: String): Array<Dynamic> {
    var retVal: Array<Dynamic> = [];
    var currentVal: Dynamic = null;
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
            leftStrVal = '%{${currentStrVal}}';
            retVal.push(currentVal);
            currentVal = null;
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
            currentVal = [null, [], null];
            parseFunc(currentVal, currentStrVal);
            retVal.push(currentVal);
            leftStrVal = currentStrVal;
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
          leftStrVal = currentStrVal;
          currentVal = null;
          currentStrVal = "";
//        case [ParsingState.LEFT_RIGHT_FUNCTION, _, OPEN_PAREN | OPEN_BRACE | OPEN_BRACKET]:
//          openCount++;
//          currentStrVal += char;
//        case [ParsingState.LEFT_RIGHT_FUNCTION, _, CLOSE_PAREN | CLOSE_BRACE | CLOSE_BRACKET]:
//          openCount--;
//          currentStrVal += char;
//        case [ParsingState.LEFT_RIGHT_FUNCTION, _, NEWLINE]:
//          if(openCount == 1) {
//            currentStrVal += CLOSE_PAREN;
//            state = ParsingState.NONE;
//            currentVal = [null, [], null];
//            parseFunc(currentVal, currentStrVal);
//            retVal.push(currentVal);
//            leftStrVal = currentStrVal;
//            currentVal = null;
//            currentStrVal = "";
//          } else {
//            currentStrVal += char;
//          }
//        case [ParsingState.LEFT_RIGHT_FUNCTION, _, _]:
//          if(openCount == 0 && leftRightOperators.any(char)) {
//            operatorStrVal += char;
//          } else {
//            if(openCount == 0) {
//              openCount++;
//              currentStrVal = '${operatorStrVal}(${leftStrVal}, ${char}';
//            } else {
//              currentStrVal += char;
//            }
//          }
        case [ParsingState.FUNCTION, _, _]:
//          if(openCount == 0 && leftRightOperators.any(char)) {
//            operatorStrVal += char;
//            state = ParsingState.LEFT_RIGHT_FUNCTION;
//            leftStrVal = currentStrVal;
//            currentStrVal = '';
//          } else {
            currentStrVal += char;
//          }

          if(currentStrVal.substr(currentStrVal.length - 2) == DO) {
            currentStrVal = currentStrVal.substr(0, currentStrVal.length - 2);

            currentVal = [null, [], null];
            if(currentStrVal != '') {
              parseFunc(currentVal, currentStrVal);
              retVal.push(currentVal);
              leftStrVal = currentStrVal;
              currentVal = null;
            }

            currentStrVal = "";
            state = ParsingState.DO;
            openCount++;
          }
        case [ParsingState.DO, _, _]:
          currentStrVal += char;
          if(currentStrVal.substr(currentStrVal.length - 2) == DO) {
            openCount++;
          } else if(currentStrVal.substr(currentStrVal.length - 3) == END) {
            openCount--;
            if(openCount == 0) {
              currentStrVal = currentStrVal.substr(0, currentStrVal.length - 3);
              var val: Array<Dynamic> = parseExpr(currentStrVal);
              if(retVal.length > 0) {
                var lastArg: Array<Dynamic> = retVal[retVal.length - 1][2];
                lastArg.push({__block__: val});
              } else {
                retVal.push(val);
              }

              leftStrVal = currentStrVal;
              currentStrVal = '';
              state = ParsingState.NONE;
            }
          }
        case [ParsingState.ATOM, _, _]:
          if(WHITESPACE.match(char)) {
            if(currentStrVal == '') {
              currentStrVal += char;
            }
            state = ParsingState.NONE;
            retVal.push(currentStrVal.trim().atom());
            leftStrVal = currentStrVal;
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
            if(DOT.match(currentStrVal)) {
              retVal.push(Std.parseFloat(currentStrVal));
            } else {
              retVal.push(Std.parseInt(currentStrVal));
            }
            leftStrVal = currentStrVal;
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
//          if(leftRightOperators.any(char)) {
//            retVal.pop();
//            state = ParsingState.LEFT_RIGHT_FUNCTION;
//            openCount++;
//            currentStrVal = '${char}(${leftStrVal},';
//          }
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
        currentVal = null;
      case ParsingState.ATOM:
        if(currentStrVal == '') {
          throw new ParsingException();
        }
        currentVal = currentStrVal.trim().atom();
        retVal.push(currentVal);
        currentVal = null;
      case ParsingState.LEFT_RIGHT_FUNCTION:
        if(openCount == 1) {
          currentStrVal += CLOSE_PAREN;
          state = ParsingState.NONE;
          currentVal = [null, [], null];
          parseFunc(currentVal, currentStrVal);
          retVal.push(currentVal);
          leftStrVal = currentStrVal;
          currentVal = null;
          currentStrVal = "";
        } else {
          throw new ParsingException();
        }
      case ParsingState.DO:
        throw new ParsingException();
      case ParsingState.COMMENT:
        //ignore
      case ParsingState.FUNCTION:
        currentVal = [null, [], null];
        parseFunc(currentVal, currentStrVal);
        retVal.push(currentVal);
        currentVal = null;
      case ParsingState.NONE:
        if(currentStrVal.length > 0) {
          currentVal = [null, [], null];
          parseFunc(currentVal, currentStrVal);
          retVal.push(currentVal);
          currentVal = null;
        }
      case _:
        throw new ParsingException();
    }

    if(retVal.length > 1) {
      retVal = [{__block__: retVal}];
    }

    return retVal;
  }

  private static inline function parseArray(array: Array<Dynamic>, string: String, spaceAsDelimiter: Bool = false): Array<Dynamic> {
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
          if(spaceAsDelimiter && WHITESPACE.match(char)) {
            var val: Array<Dynamic> = parseExpr(currentVal);
            if(val.length > 0) {
              array.push(val[0]);
            }
            currentVal = "";
          } else {
            currentVal += char;
          }
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

  private static inline function parseHash(hash: Dynamic, string: String): Dynamic {
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
          if(leftRightOperators.any(char) && openCount == 0) {
            retVal[0] = '${char}'.atom();
            currentVal = firstVal + ",";
          } else {
            currentVal += char;
          }
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
          var val: Array<Dynamic> = parseArray([], currentVal, true);
          if(val.length > 0) {
            retVal[2] = val;
          }
        }
      case _:
    }
    return retVal;
  }
}