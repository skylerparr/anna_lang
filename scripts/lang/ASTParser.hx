package lang;
import lang.LangParser;
import lang.LangParser;
import haxe.ds.ObjectMap;
import Type.ValueType;

using lang.AtomSupport;
using StringTools;
using lang.ArraySupport;
using lang.MapUtil;

@:build(macros.ScriptMacros.script())
class ASTParser {

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

  private static inline function isBasicType(string: String): Bool {
    return string == "String" ||
    string == "Int" ||
    string == "Float" ||
    string == "Dynamic" ||
    string == "Atom" ||
    string.startsWith("Array");
  }

  public static inline function getType(ast: Array<Dynamic>, aliases: Map<String, String>, context: Dynamic): String {
    var retType: String;
    var moduleAndPackage: Dynamic = resolveClassToPackage(ast, aliases, context);
    if(moduleAndPackage.packageName != '') {
      retType = ': ${moduleAndPackage.packageName.toLowerCase()}.__${moduleAndPackage.moduleName}__.${moduleAndPackage.moduleName}';
    } else {
      if(isBasicType(moduleAndPackage.moduleName)) {
        retType = ': ${moduleAndPackage.moduleName}';
      } else {
        retType = ': __${moduleAndPackage.moduleName}__.${moduleAndPackage.moduleName}';
      }
    }
    return retType;
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
        retType = getType(spec[1], aliases, context);
        for(i in 0...funArgs.length) {
          var type: String = getType(spec[0][i], aliases, context);
          var argName: String = 'arg${i}';
          typedArgs.push('${argName}${type}');
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
        var type: String = getType(spec[0][i], aliases, context);
        patternArgsDeclarations.push('    var ${funArgs[i]}${type};');
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

  public static function _deftype(ast: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    var types: Array<String> = [];
    var definedTypes: Array<Dynamic> = body[0].__block__;
    for(type in definedTypes) {
      var name: Atom = type[0];
      var type: Atom = type[1][0];
      types.push('${name.value}: ${type.value}');
    }
    var fqName: Dynamic = resolveClassToPackage(ast, aliases, context);
    var retVal: String = 'package ${fqName.packageName};${LangParser.NEWLINE}';
    retVal += 'typedef ${fqName.moduleName} = ${LangParser.OPEN_BRACE}${LangParser.NEWLINE}';
    retVal += types.join(',\n');
    retVal += LangParser.NEWLINE + LangParser.CLOSE_BRACE + LangParser.NEWLINE;
    retVal += '@:build(macros.ScriptMacros.script())
class __${fqName.moduleName}__ {}';
    return retVal;
  }

  public static function _resolveScope(ast: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    var retVal: Array<String> = [];
    var scope: Dynamic = ast[0];
    if(Std.is(scope, Atom)) {
      var a: Atom = cast(scope, Atom);
      retVal.push(a.value.toLowerCase());
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
      for(alias in LangParser.builtinAliases.keys()) {
        aliases.set(alias, LangParser.builtinAliases.get(alias));
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
      case ValueType.TClass(ObjectMap):
        var map: ObjectMap<Dynamic, Dynamic> = cast(ast, ObjectMap<Dynamic, Dynamic>);
        var dy: Dynamic = map.toDynamic();
        var dyString: String = '${dy}';
        return '${Anna.inspect(dy)}';
      case ValueType.TClass(Array):
        var vals: Array<String> = [];
        var orig: Array<Dynamic> = cast ast;
        if(orig.length == 3) {
          switch(orig) {
            case [fun, [], args]:
              if(args == 'nil'.atom()) {
                retVal = fun.value;
              } else {
                var funName: String = aliases.get(fun.value);
                if(funName == null) {
                  funName = fun.value;
                }
                var langParserFields: Array<String> = Type.getClassFields(ASTParser);
                var macroFunc: Dynamic = null;
                for(field in langParserFields) {
                  if('_${funName}' == field) {
                    macroFunc = Reflect.getProperty(ASTParser, field);
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
      case ValueType.TClass(Atom):
        retVal = '"${ast.value}".atom()';
      case ValueType.TObject:
        if(Reflect.hasField(ast, '__block__')) {
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
}