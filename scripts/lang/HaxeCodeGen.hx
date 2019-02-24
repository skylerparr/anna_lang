package lang;
import Type.ValueType;

using lang.AtomSupport;
using lang.ArraySupport;

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

  private static function prepareFunctions(moduleSpec: ModuleSpec): Dynamic {
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
    var retVal: String = '';
    var scopeVars: Map<Atom, Atom> = new Map<Atom, Atom>();
    if(funSpec.body.length > 0) {
      for(sig in funSpec.signature) {
        scopeVars.set(sig[0], sig[1]);
      }
      var body: Array<Dynamic> = funSpec.body;
      for(i in 0...body.length) {
        var expr: Array<Dynamic> = body[i];
        var fun: Atom = expr[0];
        var args: Array<Dynamic> = expr[2];
        var matchingFunctions: Array<FunctionSpec> = getMatchingInternalFunctionNames(fun, currentModule.functions);
        retVal += getFunctionToCall(fun, funSpec, args, scopeVars, matchingFunctions, i == body.length - 1);
      }
    } else {
      retVal = 'return "nil".atom();';
    }
    return retVal;
  }

  private static inline function getMatchingInternalFunctionNames(fun: Atom, functions: Array<FunctionSpec>): Array<FunctionSpec> {
    return functions.filter(function(spec: FunctionSpec): Bool { return spec.name == fun; });
  }

  private static inline function getFunctionToCall(fun: Atom, funSpec: FunctionSpec, args: Array<Dynamic>, scopeVars: Map<Atom, Atom>, matchingFunctions: Array<FunctionSpec>, isFinal: Bool): String {
    var arity: Int = args.length;
    var argTypes: Array<String> = [];
    var argVals: Array<String> = [];
    for(arg in args) {
      if(Std.is(arg, Array) && arg.length == 3) {
        if(arg[2] == 'nil'.atom()) {
          var type: Atom = scopeVars.get(arg[0]);
          argTypes.push(type.value);
          argVals.push(arg[0].value);
        } else {
          //function call
        }
      } else {
        argTypes.push(getType(arg));
        argVals.push(arg);
      }
    }

    var expectedReturnType: String = '';
    var retVal: String = '';
    if(isFinal) {
      expectedReturnType = funSpec.returnType.value;
      retVal = 'return ';
    }
    var expectedFunction: String = '${fun.value}_${arity}_${argTypes.join('_')}__${expectedReturnType}';
    var found: Bool = false;
    for(matchingFun in matchingFunctions) {
      if(matchingFun.internalName == expectedFunction) {
        found = true;
        break;
      }
    }
    if(!found) {
      throw new FunctionNotFoundException('Attempting to find function ${expectedFunction}');
    }
    retVal += '${expectedFunction}(${argVals.join(', ')})';
    return retVal + ';';
  }

  private static inline function getType(val: Dynamic): String {
    return switch(Type.typeof(val)) {
      case TInt:
        "Int";
      case TFloat:
        "Float";
      case TClass(String):
        "String";
      case _:
        //throw exception?
        '';
    }
  }

}