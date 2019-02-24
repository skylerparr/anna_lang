package lang;
import lang.LangParser;
import haxe.ds.ObjectMap;
import Type.ValueType;

using lang.AtomSupport;
using StringTools;
using lang.ArraySupport;
using lang.MapUtil;

@:build(macros.ScriptMacros.script())
class ASTParser {

  public static function _defmodule(moduleDef: Dynamic, body: Dynamic, aliases: Map<String, String>, context: Dynamic): Void {
    var fqName: Dynamic = resolveClassToPackage(moduleDef, aliases, context);
    var className: String = fqName.moduleName;
    if(className == null) {
      className = 'nil';
    }
    var moduleName: String = className;
    var packageName: String = fqName.packageName;
    if(packageName == null) {
      packageName = 'nil';
    } else {
      if(packageName == '') {
        moduleName = className;
      } else {
        moduleName = '${packageName}.${className}';
      }
    }

    Module.define(new ModuleSpec(moduleName.atom(), [], className.atom(), packageName.toLowerCase().atom()));

    context.moduleName = moduleName.atom();
    parse(body[0], aliases, context);
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
      retType = '${moduleAndPackage.packageName.toLowerCase()}.__${moduleAndPackage.moduleName}__.${moduleAndPackage.moduleName}';
    } else {
      if(isBasicType(moduleAndPackage.moduleName)) {
        retType = '${moduleAndPackage.moduleName}';
      } else {
        retType = '__${moduleAndPackage.moduleName}__.${moduleAndPackage.moduleName}';
      }
    }
    return retType;
  }

  public static function _def(defDef: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): Void {
    var retVal: String = null;
    var functionName: Atom = defDef[0];
    var functionArgsAST: Array<Dynamic> = defDef[2];

    var funArgs: Array<String> = [];
    for(funArg in functionArgsAST) {
      var haxeArg: String = parse(funArg);
      funArgs.push(haxeArg);
    }

    var retType: String = '';
    var specs: Map<Atom, Dynamic> = context.specs;
    if(specs == null) {
      specs = new Map<Atom, Dynamic>();
    }
    var spec: Dynamic = specs.get(functionName);

    var signature: Array<Array<Atom>> = [];
    for(i in 0...funArgs.length) {
      var type: String = '';
      if(spec != null) {
        type = getType(spec[0][i], aliases, context);
      }
      if(type == '') {
        type = 'nil';
      }
      signature.push([funArgs[i].atom(), type.atom()]);
    }

    if(spec != null) {
      retType = getType(spec[1], aliases, context);
    }
    if(retType == '') {
      retType = 'nil';
    }

    var functionArgs: Array<Array<Atom>> = [];
    for(key in signature) {
      functionArgs.push(key);
    }

    var moduleSpec: ModuleSpec = Module.getModule(context.moduleName);
    var internalName: String = generateInternalFunctionName(functionName, functionArgs, retType, context);
    var functionSpec: FunctionSpec = new FunctionSpec(functionName, internalName, functionArgs, retType.atom(), body[0].__block__);

    moduleSpec.functions.push(functionSpec);
    context.specs = null;
  }

  public static function generateInternalFunctionName(functionName: Atom, functionArgs: Array<Array<Atom>>, retType: String, context: Dynamic): String {
    var argTypes: Array<String> = functionArgs.map(function(args): String {
      var retVal: Atom = args[1];
      if(retVal == 'nil'.atom()) {
        return '';
      }
      return retVal.value;
    });
    var sigType: String = '';
    if(retType == 'nil') {
      sigType = '';
    } else {
      sigType = retType;
    }

    return '${functionName.value}_${argTypes.length}_${argTypes.join('_')}__${sigType}';
  }

  public static function _at_spec(specDef: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): Void {
    var funcName: Atom = specDef[0];
    if(context.specs == null) {
      context.specs = new Map<Atom, Dynamic>();
    }
    var specs: Map<Atom, Dynamic> = context.specs;
    specs.set(funcName, body);
  }
  
  public static function _resolveScope(ast: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): String {
    var retVal: Array<String> = [];
    var scope: Dynamic = ast[0];
    if(Std.is(scope, Atom)) {
      var a: Atom = cast(scope, Atom);
      retVal.push(a.value);
      retVal.push(parse(body[0]));
    }
    return retVal.join('.');
  }

  private static function resolveClassToPackage(ast: Array<Dynamic>, aliases: Map<String, String>, context: Dynamic): Dynamic {
    var fqName: String = parse(ast, aliases, context);
    var modName: String = fqName.split('(')[0];
    var frags: Array<String> = modName.split('.');
    var moduleName: String = frags.pop();
    var packageName: String = frags.join('.');
    return {packageName: packageName, moduleName: moduleName};
  }

  public static function parse(ast: Dynamic, aliases: Map<String, String> = null, context: Dynamic = null): String {
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
                    parsedArgs.push(parse(arg, aliases, context));
                  }
                  retVal = '${funName}(${parsedArgs.join(", ")})';
                }
              }
            case _:
              throw new ParsingException();
          }
        } else {
          for(val in orig) {
            vals.push(parse(val, aliases, context));
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
            var haxeString: String = parse(val, aliases, context);
            if(haxeString != null) {
              vals.push(haxeString);
            }
          }
          retVal = vals.join("\n");
        } else {
          var vals: Array<String> = [];
          var fields: Array<String> = Reflect.fields(ast);
          for(field in fields) {
            vals.push('${parse(field, aliases, context)}: ${parse(Reflect.field(ast, field), aliases, context)}');
          }
          retVal = '{${vals.join(", ")}}';
        }
      case _:
        throw new ParsingException();
    }
    return retVal;
  }
}