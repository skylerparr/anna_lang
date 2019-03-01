package lang;
import Type.ValueType;

using lang.AtomSupport;
using lang.ArraySupport;
using StringTools;

@:build(macros.ScriptMacros.script())
class HaxeCodeGen {

  private static inline var classTemplate: String = "package ::packageName::;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class ::className:: {
::foreach functions::
  public static function ::internalName::(::signatureString::)::returnTypeString:: {
    ::body::
  }
::end::
}";

  public static function generate(moduleSpec: ModuleSpec): String {
    var template = new haxe.Template(classTemplate);

    var functions: Array<Dynamic> = prepareFunctions(moduleSpec);

    var args: Dynamic = {
      className: moduleSpec.className.value,
      packageName: moduleSpec.packageName.value,
      functions: functions,
    };

    var output: String = template.execute(args);
    return output;
  }

  private static inline function prepareFunctions(moduleSpec: ModuleSpec): Dynamic {
    var retVal: Array<Dynamic> = [];
    var functionSpecs: Array<FunctionSpec> = moduleSpec.functions;

    for(fun in functionSpecs) {
      var funSpec: Dynamic = {};
      funSpec.internalName = fun.internalName;
      funSpec.signatureString = getSignatureString(fun.signature);
      funSpec.returnTypeString = getReturnTypeString(fun.returnType);
      funSpec.body = buildFunctionBody(fun, moduleSpec);
      retVal.push(funSpec);
    }

    return retVal;
  }

  private static inline function getSignatureString(signature: Array<Array<Atom>>): String {
    var retVal: Array<String> = [];
    for(sign in signature) {
      var argStr: String = '';
      if(sign[1] != 'nil'.atom()) {
        argStr = '${sign[0].value}: ${sign[1].value}';
      } else {
        argStr = sign[0].value;
      }
      retVal.push(argStr);
    }
    return retVal.join(', ');
  }

  private static inline function getReturnTypeString(returnType: Atom): String {
    var retVal: String = '';
    if(returnType != 'nil'.atom()) {
      retVal = ': ${returnType.value}';
    }
    return retVal;
  }

  private static inline function buildFunctionBody(funSpec: FunctionSpec, currentModule: ModuleSpec): String {
    var retVal: String = 'return ';
    var scopeVars: Map<Atom, Atom> = new Map<Atom, Atom>();
    if(funSpec.body.length > 0) {
      for(sig in funSpec.signature) {
        scopeVars.set(sig[0], sig[1]);
      }
      var body: Array<Dynamic> = funSpec.body;
      for(i in 0...body.length) {
        var expr: Array<Dynamic> = body[i];
        var fun: Atom = expr[0];
        var expr2: Dynamic = expr[2];
        if(expr2 == 'nil'.atom()) {
          retVal += '${fun.value}';
        } else {
          var args: Array<Dynamic> = expr2;
          var matchingFunctions: Array<FunctionSpec> = getMatchingInternalFunctionNames(fun, currentModule.functions);
          var expectedReturnType: Atom = funSpec.returnType;
          retVal += getFunctionToCall(fun, expectedReturnType, args, currentModule, scopeVars, matchingFunctions);
        }
      }
    } else {
      retVal += '"nil".atom()';
    }
    return '${retVal};';
  }

  private static inline function getMatchingInternalFunctionNames(fun: Atom, functions: Array<FunctionSpec>): Array<FunctionSpec> {
    return functions.filter(function(spec: FunctionSpec): Bool { return spec.name == fun; });
  }

  private static inline function getFunctionToCall(fun: Atom, expectedReturnType: Atom, args: Array<Dynamic>, currentModule: ModuleSpec, scopeVars: Map<Atom, Atom>, matchingFunctions: Array<FunctionSpec>): String {
    var arity: Int = args.length;
    var argTypes: Array<String> = [];
    var argVals: Array<String> = [];
    var argIndex: Int = 0;
    for(arg in args) {
      if(Std.is(arg, Array) && arg.length == 3) {
        if(arg[2] == 'nil'.atom()) {
          var type: Atom = scopeVars.get(arg[0]);
          if(type == 'nil'.atom()) {
            argTypes.push('');
          } else {
            argTypes.push(type.value);
          }
          argVals.push(arg[0].value);
        } else {
          var expr: Array<Dynamic> = arg;
          var args: Array<Dynamic> = expr[2];
          var scopedModule: ModuleSpec = currentModule;
          var packagePrefix: String = '';

          var fun: Atom = expr[0];
          if(fun == '.'.atom()) {
            var astCopy: Array<Dynamic> = expr[2].copy();
            var fullModuleName: String = ASTParser._resolveScope(astCopy.shift(), astCopy, null, null);
            var functionAST = ASTParser.getScopedFunction(astCopy);

            var classPack: Dynamic = ASTParser.annaModuleToHaxe(fullModuleName);
            var module: Atom = '${classPack.packageName}.${classPack.moduleName}'.atom();
            fun = functionAST[0];
            args = functionAST[2];
            scopedModule = Module.getModule(module);
            packagePrefix = '${classPack.packageName.toLowerCase()}.${classPack.moduleName}.';
          } else {
            fun = expr[0];
          }
          var matchingFunctions: Array<FunctionSpec> = getMatchingInternalFunctionNames(fun, scopedModule.functions);
          var possibleFunctionCalls: Array<String> = [];
          var possibleFunctions: Array<FunctionSpec> = [];
          for(functions in matchingFunctions) {
            var returnType: Atom = functions.signature[argIndex][1];
            var funStr: String = getFunctionToCall(fun, returnType, args, scopedModule, scopeVars, matchingFunctions);
            possibleFunctions.push(getFunctionSpec(funStr, scopedModule));
            possibleFunctionCalls.push('${packagePrefix}${funStr}');
          }
          if(possibleFunctions.length == 1) {
            var func: FunctionSpec = possibleFunctions[0];
            if(func.returnType == 'nil'.atom()) {
              argTypes.push('');
            } else {
              argTypes.push(func.returnType.value);
            }
            argVals.push(possibleFunctionCalls[0]);
          } else {

          }
        }
      } else {
        argTypes.push(getType(arg));
        argVals.push(arg);
      }
      argIndex++;
    }

    var expectedReturnTypeStr: String = expectedReturnType.value;
    if(expectedReturnTypeStr == 'nil') {
      expectedReturnTypeStr = '';
    }

    var expectedFunction: String = '${fun.value}_${arity}_${argTypes.join('_')}__${expectedReturnTypeStr}';
    var matchedFuncSpec: FunctionSpec = null;
    for(matchingFun in matchingFunctions) {
      if(matchingFun.internalName == expectedFunction) {
        matchedFuncSpec = matchingFun;
        break;
      }
    }
    if(matchedFuncSpec == null) {
      throw new FunctionNotFoundException('Could not find function ${expectedFunction}');
    }
    return '${expectedFunction}(${argVals.join(', ')})';
  }

  public static inline function getFunctionSpec(functionCall: String, moduleSpec: ModuleSpec): FunctionSpec {
    var retVal: FunctionSpec = null;
    var funcName: String = functionCall.split('(')[0];
    for(func in moduleSpec.functions) {
      if(func.internalName == funcName) {
        retVal = func;
      }
    }
    if(retVal == null) {
      throw new FunctionNotFoundException('Could not find function spec for ${functionCall}');
    }

    return retVal;
  }

  private static inline function getType(val: Dynamic): String {
    return switch(Type.typeof(val)) {
      case TInt:
        "Int";
      case TFloat:
        "Float";
      case TClass(String):
        "String";
      case TNull:
        throw new FunctionNotFoundException('Encountered null type');
      case t:
        //throw exception?
        trace(t);
        '';
    }
  }

}