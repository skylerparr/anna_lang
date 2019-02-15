package lang;

import lang.Types;
import compiler.CodeGen;
import Type.ValueType;
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
    builtinAliases.set('=', 'patternMatch');
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

  public static function _defmodule(moduleDef: Dynamic, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    var fqName: Dynamic = resolveClassToPackage(moduleDef, aliases, context);
    var moduleName: String = fqName.moduleName;
    context.moduleName = moduleName;
    var retVal: String =
'package ${fqName.packageName};
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
        var moduleAndPackage: Dynamic = resolveClassToPackage(spec[1], aliases, context);
        if(moduleAndPackage.packageName != '') {
          retType = ': ${moduleAndPackage.packageName}.__${moduleAndPackage.moduleName}__.${moduleAndPackage.moduleName}';
        } else {
          if(moduleAndPackage.moduleName != "String" &&
            moduleAndPackage.moduleName != "Int" &&
            moduleAndPackage.moduleName != "Float" &&
            moduleAndPackage.moduleName != "Dynamic" ) {
            retType = ': __${moduleAndPackage.moduleName}__.${moduleAndPackage.moduleName}';
          } else {
            retType = ': ${moduleAndPackage.moduleName}';
          }
        }
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
          funBody.push('var v${counter++} = ${toHaxe(expr)};');
        }
      } else {
        funBody.push('var v${counter++} = ${toHaxe(expr)};');
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

  public static function _deftype(ast: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {

    var types: Array<String> = [];
    var definedTypes: Array<Dynamic> = body[0].__block__;
    for(type in definedTypes) {
      var name: Atom = type[0];
      var type: Atom = type[1][0];
      types.push('${name.value}: ${type.value}');
    }
    var fqName: Dynamic = resolveClassToPackage(ast, aliases, context);
    var retVal: String = 'package ${fqName.packageName};${NEWLINE}';
    retVal += 'typedef ${fqName.moduleName} = ${OPEN_BRACE}${NEWLINE}';
    retVal += types.join(',\n');
    retVal += NEWLINE + CLOSE_BRACE + NEWLINE;
    retVal += '@:build(macros.ScriptMacros.script())
class __${fqName.moduleName}__ {}';
    return retVal;
  }

  public static function _resolveScope(ast: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    var retVal: Array<String> = [];
    var scope: Dynamic = ast[0];
    if(Reflect.hasField(scope, '__type__') && Reflect.field(scope, '__type__') == 'ATOM') {
      retVal.push(AtomUtil.toString(scope).toLowerCase());
      retVal.push(toHaxe(body[0]));
    }
    return retVal.join('.');
  }

  private static function resolveClassToPackage(ast: Array<Dynamic>, aliases: Map<String, String>, context: Dynamic): Dynamic {
    var fqName: String = toHaxe(ast, aliases, context);
    var modName: String = fqName.split('(')[0];
    var frags: Array<String> = modName.split('.');
    var moduleName: String = frags.pop();
    var packageName: String = frags.join('.');
    return {packageName: packageName, moduleName: moduleName};
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
      case ValueType.TNull:
        trace(retVal);
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
            currentVal = null;
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
      case ParsingState.DO:
        retVal = parseDoBlock(retVal, leftStrVal, currentStrVal);
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
    // AST: [[{ __type__ => ATOM, value => defmodule },[],[[{ __type__ => ATOM, value => Foo },[],null]]]]
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