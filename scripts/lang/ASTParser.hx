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

  public static function _defmodule(moduleDef: Dynamic, body: Dynamic, aliases: Map<String, String>, context: Dynamic): Void {
    var fqName: Dynamic = resolveClassToPackage(moduleDef, aliases, context);
    var moduleName: String = fqName.moduleName;

    Module.define(new ModuleSpec(moduleName.atom(), []));

    context.moduleName = moduleName.atom();
    toHaxe(body[0], aliases, context);
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
    var functionName: String = defDef[0].value;
    var functionArgsAST: Array<Dynamic> = defDef[2];

    var funArgs: Array<String> = [];
    for(funArg in functionArgsAST) {
      var haxeArg: String = toHaxe(funArg);
      funArgs.push(haxeArg);
    }

    var retType: String = '';
    var specs: Map<String, Dynamic> = context.specs;
    var signature: Array<Array<Atom>> = [];
    var spec: Dynamic = null;
    for(i in 0...funArgs.length) {
      var type: String = '';
      if(specs != null) {
        spec = specs.get(functionName);
        if(spec != null) {
          retType = getType(spec[1], aliases, context);
          type = getType(spec[0][i], aliases, context);
        }
      }
      if(type == '') {
        type = 'nil';
      }
      if(retType == '') {
        retType = 'nil';
      }
      signature.push([funArgs[i].atom(), type.atom()]);
    }

    var functionArgs: Array<Array<Atom>> = [];
    for(key in signature) {
      functionArgs.push(key);
    }

    var moduleSpec: ModuleSpec = Module.getModule(context.moduleName);
    var functionSpec: FunctionSpec = new FunctionSpec(functionName.atom(), functionArgs, retType.atom(), body[0].__block__);

    moduleSpec.functions.push(functionSpec);
  }

  public static function _at_spec(specDef: Array<Dynamic>, body: Dynamic, aliases: Map<String, String>, context: Dynamic): Void {
    var funcName: String = specDef[0].value;
    if(context.specs == null) {
      context.specs = new Map<String, Dynamic>();
    }
    var specs: Map<String, Dynamic> = context.specs;
    specs.set(funcName, body);
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