package lang.macros;

import hscript.plus.ParserPlus;
import haxe.macro.Printer;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;
class AnnaLang {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  private static var declaredFunctions: Map<String, TypeDefinition> = new Map<String, TypeDefinition>();

  macro public static function defcls(name: Expr, body: Expr): Array<Field> {
    MacroLogger.log('==============================');
    var className: String = printer.printExpr(name);
    MacroLogger.log(className, 'name');
    MacroLogger.logExpr(body, 'bodyString');

    var cls = MacroTools.createClass(className);
    MacroContext.currentModule = cls;
    MacroContext.aliases = new Map<String, String>();
    MacroContext.declaredFunctions = new Map<String, Array<Dynamic>>();
    applyBuildMacro();

    prewalk(body);

    for(key in MacroContext.declaredFunctions.keys()) {
      for(funDef in MacroContext.declaredFunctions.get(key)) {
        MacroContext.currentFunction = funDef.name;
        MacroContext.currentFunctionArgTypes = [];
        MacroContext.varTypesInScope = new Map<String, String>();
        MacroContext.lastFunctionReturnType = "";

        // Actual operations this function will be doing
        var funBody = funDef.funBody;
        var body: Array<Expr> = [];
        var varName: String = 'var args: Array<vm.Operation> = [];';

        MacroContext.currentVar = 'args';
        body.push(Macros.haxeToExpr(varName));

        var funBodies: Array<Dynamic> = cast(funDef.funBody, Array<Dynamic>);
        for(bodyExpr in funBodies) {
          var walkBody = walkBlock(bodyExpr);
          for(expr in walkBody) {
            body.push(expr);
          }
        }
        var ret = MacroTools.buildConst(CIdent('args'));
        body.push(ret);

        var internalFunctionName: String = funDef.internalFunctionName;
        var varType: ComplexType = MacroTools.buildType('Array<vm.Operation>');
        var pubVar = MacroTools.buildPublicVar('_${internalFunctionName}', varType, body);
        MacroTools.addFieldToClass(MacroContext.currentModule, pubVar);

        // Function
        var returnType: ComplexType = MacroTools.buildType('Array<vm.Operation>');
        var funArgs: Array<FunctionArg> = [];
        var funArgsTypes: Array<Dynamic> = funDef.funArgsTypes;
        for(funArgsType in funArgsTypes) {
          funArgs.push({name: funArgsType.name, type: MacroTools.buildType(funArgsType.type)});
        }
        var field: Field = MacroTools.buildPublicFunction(internalFunctionName, funArgs, returnType);
        var expr: Expr = MacroTools.buildReturn(MacroTools.buildConst(CIdent('_${internalFunctionName}')));
        MacroTools.assignFunBody(field, MacroTools.buildBlock([expr]));
        MacroTools.addFieldToClass(MacroContext.currentModule, field);

        // Arg types
        var exprs: Array<Expr> = [];
        var varType: ComplexType = MacroTools.buildType('Array<String>');
        exprs.push(Macros.haxeToExpr('var args: Array<String> = [];'));
        for(funArgs in funArgsTypes) {
          var haxeExpr = Macros.haxeToExpr('args.push("${funArgs.name}");');
          exprs.push(haxeExpr);
        }
        var ret = MacroTools.buildConst(CIdent('args'));
        exprs.push(ret);
        var argFun = MacroTools.buildPublicVar('___${funDef.name}_${funDef.argTypes}_args', varType, exprs);
        MacroTools.addFieldToClass(MacroContext.currentModule, argFun);
      }
    }

    Context.defineType(cls);

    MacroLogger.log("==================");
    MacroLogger.log('Fields for ${className}');
    MacroLogger.log('------------------');
    MacroLogger.printFields(cls.fields);
    MacroLogger.log("------------------");
    return [];
  }

  #if macro
  private static function prewalk(expr: Expr): Void {
    switch(expr.expr) {
      case EBlock(exprs):
        for(blockExpr in exprs) {
          switch(blockExpr.expr) {
            case EMeta({name: name}, params):
              var fun = Reflect.field(AnnaLang, '_${name}');
              fun(params);
            case e:
              MacroLogger.log(e, 'e');
              throw "AnnaLang Prewalk: Not sure what to do here yet";
          }
        }
      case e:
        MacroLogger.log(e, 'e');
        throw "AnnaLang Prewalk: Not sure what to do here yet";
    }
  }

  private static function walkBlock(expr: Expr): Array<Expr> {
    var retExprs: Array<Expr> = [];
    switch(expr.expr) {
      case EBlock(exprs):
        for(blockExpr in exprs) {
          switch(blockExpr.expr) {
            case EMeta({name: name}, params):
              var fun = Reflect.field(AnnaLang, '_${name}');
              var expr = fun(params);
              retExprs.push(expr);
            case ECall(expr, args):
              var funName: String = MacroTools.getCallFunName(blockExpr);
              var args: Array<Expr> = MacroTools.getFunBody(blockExpr);
              var lineNumber: Int = MacroTools.getLineNumber(expr);
              var expr: Expr = createPushStack(funName, args, lineNumber);
              retExprs.push(expr);
            case EBinop(OpAssign, left, right):
              var lineNumber = MacroTools.getLineNumber(right);
              var exprs = walkBlock(MacroTools.buildBlock([right]));
              for(expr in exprs) {
                retExprs.push(expr);
              }
              var assignOp: Expr = createAssign(left, lineNumber);
              retExprs.push(assignOp);
            case EConst(CString(value)) | EConst(CInt(value)) | EConst(CFloat(value)) | EConst(CIdent(value)):
              var lineNumber = MacroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case EArrayDecl(values):
              var lineNumber = MacroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case EBlock(values):
              var lineNumber = MacroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case things:
              MacroLogger.log(things, 'things');
              blockExpr;
          }
        }
      case EConst(ident):
      case EMeta({name: name}, _):
        MacroContext.currentFunctionArgTypes.push(name);
      case EObjectDecl(_) | EArrayDecl(_):
      case e:
        MacroLogger.log(e, 'e');
        throw "AnnaLang: Not sure what to do here yet";
    }
    return retExprs;
  }

  private static function applyBuildMacro():Void {
    var cls: TypeDefinition = MacroContext.currentModule;
    var metaConst = MacroTools.buildConst(CIdent('Macros'));
    var metaField = MacroTools.buildExprField(metaConst, 'build');
    var metaCall = MacroTools.buildCall(metaField, []);
    var metaData = MacroTools.buildMeta(':build', [metaCall]);
    MacroTools.addMetaToClass(cls, metaData);
  }

  private static function createPushStack(funName: String, args: Array<Expr>, lineNumber: Int):Expr {
    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    var currentFunStr: String = MacroContext.currentVar;
    var types: Array<String> = [];
    var funArgs: Array<String> = [];
    for(arg in args) {
      var typeAndValue = MacroTools.getTypeAndValue(arg);
      var type: String = getTypeForVar(typeAndValue, arg);
      types.push(type);
      funArgs.push(typeAndValue.value);
    }
    funName = '${funName}_${types.join("_")}';

    var funDef: Dynamic = MacroContext.declaredFunctions.get(funName);

    MacroContext.lastFunctionReturnType = funDef[0].funReturnTypes[0];
    var haxeStr: String = '${currentFunStr}.push(new vm.PushStack(@atom "${currentModuleStr}", @atom "${funName}", @list [${funArgs.join(", ")}], @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${lineNumber}))';
    return Macros.haxeToExpr(haxeStr);
  }

  private static function getTypeForVar(typeAndValue: Dynamic, arg: Expr):String {
    return switch(arg.expr) {
      case EConst(CIdent(varName)):
        var type = MacroContext.varTypesInScope.get(varName);
        getType(type);
      case _:
        getType(typeAndValue.type);
    }
  }

  private static function getType(type: String):String {
    return switch(type) {
      case "Int" | "Float":
        "Number";
      case _:
        type;
    }
  }

  public static function createAssign(expr: Expr, lineNumber: Int): Expr {
    var moduleName: String = MacroTools.getModuleName(expr);
    moduleName = getAlias(moduleName);

    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    var currentFunStr: String = MacroContext.currentVar;
    var varName: String = MacroTools.getIdent(expr);
    MacroContext.varTypesInScope.set(varName, MacroContext.lastFunctionReturnType);
    var haxeStr: String = '${currentFunStr}.push(new vm.Match(@list [@tuple[@atom "const", "${varName}"]], @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${lineNumber}));';
    return Macros.haxeToExpr(haxeStr);
  }

  private static function createPutIntoScope(expr: Expr, lineNumber: Int):Expr {
    var moduleName: String = MacroTools.getModuleName(expr);
    moduleName = getAlias(moduleName);

    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    var currentFunStr: String = MacroContext.currentVar;

    var args = MacroTools.getFunBody(expr);
    var strArgs: Array<String> = [];
    for(arg in args) {
      var typeAndValue = MacroTools.getTypeAndValue(arg);
      strArgs.push(typeAndValue.value);
    }
    MacroContext.lastFunctionReturnType = getAnnaVarConstType(Macros.haxeToExpr(strArgs.join(";")));

    var haxeStr: String = '${currentFunStr}.push(new vm.PutInScope(${strArgs.join(", ")}, @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${lineNumber}));';
    return Macros.haxeToExpr(haxeStr);
  }

  public static function __(params: Expr):Expr {
    var haxeStr: String = '@atom"${MacroTools.extractFullFunCall(params)[0]}";';
    return createPutIntoScope(Macros.haxeToExpr(haxeStr), MacroTools.getLineNumber(params));
  }

  public static function _def(params: Expr): Expr {
    var funName: String = MacroTools.getCallFunName(params);
    var allTypes: Dynamic = MacroTools.getArgTypesAndReturnTypes(params);
    var funArgsTypes: Array<Dynamic> = allTypes.argTypes;
    var types: Array<String> = [];
    for(argType in funArgsTypes) {
      types.push(getType(argType.type));
    }
    var argTypes: String = StringTools.replace(types.join('_'), ".", "_");
    var funBody: Array<Expr> = MacroTools.getFunBody(params);

    var internalFunctionName: String = '${funName}_${argTypes}';

    // add the functions to the context for reference later
    var funBodies: Array<Dynamic> = MacroContext.declaredFunctions.get(internalFunctionName);
    if(funBodies == null) {
      funBodies = [];
    }
    var def = {
      name: funName,
      internalFunctionName: internalFunctionName,
      argTypes: argTypes,
      funArgsTypes: funArgsTypes,
      funReturnTypes: allTypes.returnTypes,
      funBody: funBody
    };
    funBodies.push(def);
    MacroContext.declaredFunctions.set(internalFunctionName, funBodies);

    return macro {};
  }

  public static function _alias(params: Expr):Expr {
    var fun = MacroTools.getCallFunName(params);
    var fieldName = MacroTools.getAliasName(params);

    MacroContext.aliases.set(fieldName, fun);
    return macro {};
  }

  public static function getAlias(str: String):String {
    return switch(MacroContext.aliases.get(str)) {
      case null:
        str;
      case val:
        val;
    }
  }

  public static function _native(params: Expr):Expr {
    var funName: String = MacroContext.currentVar;
    var moduleName: String = MacroTools.getModuleName(params);
    moduleName = getAlias(moduleName);
    var invokeFunName = MacroTools.getFunctionName(params);
    var args = MacroTools.getFunBody(params);
    var strArgs: Array<String> = [];
    for(arg in args) {
      var typeAndValue = MacroTools.getTypeAndValue(arg);
      strArgs.push(typeAndValue.value);
    }
    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;

    var invokeClass: TypeDefinition = createOperationClass(moduleName, invokeFunName, strArgs);

    var haxeString = '${funName}.push(new vm.${invokeClass.name}(${moduleName}.${invokeFunName}, @list[${strArgs.join(', ')}],
      @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${MacroTools.getLineNumber(params)}))';
    var retVal = Macros.haxeToExpr(haxeString);
    return retVal;
  }

  private static function createOperationClass(moduleName: String, invokeFunName: String, strArgs: Array<String>): TypeDefinition {
    var className = 'InvokeFunction_${StringTools.replace(invokeFunName, '.', '_')}';

    var assignments: Array<String> = [];
    var paramVars: Array<Field> = [];
    var counter: Int = 0;
    var privateArgs: Array<String> = [];
    for(arg in strArgs) {
      var assign: String = '
          var _arg${counter} = {
            switch(cast(lang.EitherSupport.getValue(arg${counter}[0]), Atom)) {
              case {value: "const"}:
                lang.EitherSupport.getValue(arg${counter}[1]);
              case {value: "var"}:
                scope.get(lang.EitherSupport.getValue(arg${counter}[1]));
              case _:
                throw "AnnaLang: Unexpected function argument";
            }
          };';
      var classVar: String = 'arg${counter}';
      var paramVar = macro class Fake {
        private var $classVar: Array<EitherEnums.Either2<Atom, Dynamic>>;
      }
      paramVars.push(paramVar.fields[0]);
      assignments.push(assign);
      privateArgs.push('_arg${counter}');
      ++counter;
    }
    var executeBodyStr: String = '${assignments.join('\n')} ${moduleName}.${invokeFunName}(${privateArgs.join(', ')});';

    // save the return type in compiler scope to check types later
    var args: Array<String> = privateArgs.map(function(arg) { return 'null'; });
    var expr: Expr = Macros.haxeToExpr('${moduleName}.${invokeFunName}(${args.join(', ')})');
    var type: Type = Context.typeof(expr);
    switch(type) {
      case TInst(t, _):
        MacroContext.lastFunctionReturnType = t.toString();
      case TAbstract(t, _):
        MacroContext.lastFunctionReturnType = t.toString();
      case TDynamic(_):
        MacroContext.lastFunctionReturnType = "Dynamic";
      case t:
        MacroLogger.log(t, 't');
        throw "AnnaLang: Unhandled return type";
    }

    if(declaredFunctions.get(className) == null) {
      var assignReturnVar: Expr = null;
      if(MacroContext.lastFunctionReturnType == "Int" || MacroContext.lastFunctionReturnType == "Float") {
        assignReturnVar = macro scope.set("$$$", retVal);
        MacroContext.lastFunctionReturnType = "Float";
      } else {
        assignReturnVar = macro if(retVal == null) {
              scope.set("$$$", lang.HashTableAtoms.get("nil"));
            } else {
              scope.set("$$$", retVal);
            }
      }

      var execBody: Expr = Macros.haxeToExpr(executeBodyStr);
      var cls: TypeDefinition = macro class NoClass extends vm.AbstractInvokeFunction {

          public function new(func: Dynamic, args: LList, hostModule: Atom, hostFunction: Atom, line: Int) {
            super(hostModule, hostFunction, line);
            var counter: Int = 0;
            for(arg in LList.iterator(args)) {
                var tuple: Tuple = lang.EitherSupport.getValue(arg);
                var argArray = tuple.asArray();
                Reflect.setField(this, "arg" + (counter++), argArray);
              }
          }

          override public function execute(scope: Map<String, Dynamic>, processStack: vm.ProcessStack): Void {
            var retVal = $e{execBody}
            $e{assignReturnVar}
          }
      }

      for(paramVar in paramVars) {
        MacroTools.addFieldToClass(cls, paramVar);
      }

      cls.name = className;
      cls.pack = ["vm"];

      Context.defineType(cls);

      declaredFunctions.set(className, cls);
      return cls;
     } else {
      return declaredFunctions.get(className);
    }
  }

  private static function getAnnaVarConstType(expr):String {
    return switch(expr.expr) {
      case EMeta({name: 'tuple'}, {expr: EArrayDecl([_, e])}):
        var typeAndValue: Dynamic = MacroTools.getTypeAndValue(e);
        typeAndValue.type;
      case e:
        MacroLogger.log(e, 'e');
        throw "AnnaLang: Unexpected constant";
    }
  }

  #end

}