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
  private static var uniqueId: Int = 0;

  macro public static function init(): Array<Field> {
    MacroContext.declaredClasses = new Map<String, ModuleDef>();
    return [];
  }

  macro public static function compile(): Array<Field> {
    for(className in MacroContext.declaredClasses.keys()) {
      var moduleDef: ModuleDef = MacroContext.declaredClasses.get(className);
      MacroContext.currentModuleDef = moduleDef;
      MacroContext.aliases = moduleDef.aliases;
      var cls = MacroTools.createClass(className);
      MacroContext.currentModule = cls;
      MacroContext.declaredFunctions = moduleDef.declaredFunctions;
      applyBuildMacro();

      var definedFunctions: Map<String, String> = new Map<String, String>();

      while(!allFunctionsDefined(definedFunctions)) {
        var index: Int = 0;
        var prevFunctionName: String = null;
        var funNameFunDefMap: Map<String, Array<Dynamic>> = new Map<String, Array<Dynamic>>();

        var declaredFunctions: Map<String, Array<Dynamic>> = getUndefinedFunctions(definedFunctions);
        for(key in declaredFunctions.keys()) {
          definedFunctions.set(key, key);
          for(funDef in declaredFunctions.get(key)) {
            MacroContext.currentFunction = funDef.name;
            MacroContext.currentFunctionArgTypes = [];
            MacroContext.varTypesInScope = new Map<String, String>();
            MacroContext.lastFunctionReturnType = "";

            // Actual operations this function will be doing
            var funBody = funDef.funBody;
            var body: Array<Expr> = [];
            var varName: String = 'var ops: Array<vm.Operation> = [];';

            MacroContext.currentVar = 'ops';
            body.push(Macros.haxeToExpr(varName));

            var funBodies: Array<Dynamic> = cast(funDef.funBody, Array<Dynamic>);
            for(bodyExpr in funBodies) {
              var walkBody = walkBlock(bodyExpr);
              for(expr in walkBody) {
                body.push(expr);
              }
            }
            var ret = MacroTools.buildConst(CIdent('ops'));
            body.push(ret);

            var internalFunctionName: String = funDef.internalFunctionName;
            if(prevFunctionName == internalFunctionName) {
              index++;
            } else {
              index = 0;
            }
            prevFunctionName = internalFunctionName;
            var varType: ComplexType = MacroTools.buildType('Array<vm.Operation>');
            var pubVar = MacroTools.buildPublicVar('_${internalFunctionName}_${index}', varType, body);
            MacroTools.addFieldToClass(MacroContext.currentModule, pubVar);

            // Function
            var funDefs: Array<Dynamic> = funNameFunDefMap.get(internalFunctionName);
            if(funDefs == null) {
              funDefs = [];
            }
            funDefs.push(funDef);
            funNameFunDefMap.set(internalFunctionName, funDefs);

            // Arg types
            var funArgsTypes: Array<Dynamic> = funDef.funArgsTypes;
            var exprs: Array<Expr> = [];
            var varType: ComplexType = MacroTools.buildType('Array<String>');
            exprs.push(Macros.haxeToExpr('var args: Array<String> = [];'));
            for(funArgs in funArgsTypes) {
              var haxeExpr = Macros.haxeToExpr('args.push("${funArgs.name}");');
              exprs.push(haxeExpr);
            }
            var ret = MacroTools.buildConst(CIdent('args'));
            exprs.push(ret);
            var argFun = MacroTools.buildPublicVar('___${funDef.name}_${funDef.argTypes}_${index}_args', varType, exprs);
            MacroTools.addFieldToClass(MacroContext.currentModule, argFun);
          }
        }

        var fieldMap: Map<String, String> = new Map<String, String>();
        for(internalFunctionName in funNameFunDefMap.keys()) {
          // After all the fields have been added to the class, generate the accompanying function that
          // will handle function head pattern matching
          var funDefs: Array<Dynamic> = funNameFunDefMap.get(internalFunctionName);
          var patternTest: String = '';
          index = 0;
          var field: Field = null;
          for(funDef in funDefs) {
            var funArgsTypes: Array<Dynamic> = cast funDef.funArgsTypes;
            var returnType: ComplexType = MacroTools.buildType('Array<vm.Operation>');
            var funArgs: Array<FunctionArg> = [];
            var patternMatches: Array<String> = [];
            var patternCounter: Int = 0;
            for(funArgsType in funArgsTypes) {
              funArgs.push({name: funArgsType.name, type: MacroTools.buildType(funArgsType.type)});
              var haxeStr: String = '';
              if(funArgsType.pattern != funArgsType.name) {
                haxeStr = 'var match${patternCounter++}: Map<String, Dynamic> = lang.macros.PatternMatch.match(${funArgsType.pattern}, ${funArgsType.name});';
              }
              patternMatches.push(haxeStr);
            }
            funArgs.push({name: "____scopeVariables", type: MacroTools.buildType('Map<String, Dynamic>')});
            if(field == null) {
              field = MacroTools.buildPublicFunction(internalFunctionName, funArgs, returnType);
            }
            if(patternMatches.length > 0) {
              var matchStatements: Array<String> = [];
              var patternIndex: Int = 0;
              for(pattenMatch in patternMatches) {
                if(pattenMatch != "") {
                  matchStatements.push('match${patternIndex} != null');
                  patternIndex++;
                }
              }
              patternTest += patternMatches.join("\n");
              if(matchStatements.length > 0) {
                patternTest += 'if(${matchStatements.join(" && ")})';
              }
            }
            patternTest += 'return _${internalFunctionName}_${index};';
            index++;
          }
          patternTest += 'return null;';
          var patternExpr: Expr = Macros.haxeToExpr(patternTest);
          MacroTools.assignFunBody(field, patternExpr);
          patternTest = '';
          MacroTools.addFieldToClass(MacroContext.currentModule, field);
        }
      }

      Context.defineType(cls);

      MacroLogger.log("==================");
      MacroLogger.log('Fields for ${className}');
      MacroLogger.log('------------------');
      MacroLogger.printFields(cls.fields);
      MacroLogger.log("------------------");

    }
    return [];
  }

  macro public static function defcls(name: Expr, body: Expr): Array<Field> {
    MacroLogger.log('==============================');
    var className: String = printer.printExpr(name);
    var moduleDef: ModuleDef = new ModuleDef(className);
    MacroContext.aliases = new Map<String, String>();
    MacroContext.declaredFunctions = new Map<String, Array<Dynamic>>();
    MacroLogger.log(className, 'name');
    MacroLogger.logExpr(body, 'bodyString');

    prewalk(body);
    MacroContext.declaredClasses.set(className, moduleDef);
    moduleDef.aliases = MacroContext.aliases;
    moduleDef.declaredFunctions = MacroContext.declaredFunctions;

    return [];
  }

  #if macro

  private static function allFunctionsDefined(definedFunctions: Map<String, String>):Bool {
    for(key in MacroContext.declaredFunctions.keys()) {
      if(definedFunctions.get(key) == null) {
        return false;
      }
    }
    return true;
  }

  private static function getUndefinedFunctions(definedFunctions: Map<String, String>):Map<String, Array<Dynamic>> {
    var retVal = new Map<String, Array<Dynamic>>();
    for(key in MacroContext.declaredFunctions.keys()) {
      if(definedFunctions.get(key) == null) {
        retVal.set(key, MacroContext.declaredFunctions.get(key));
      }
    }
    return retVal;
  }

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
            case EMeta({name: '_'}, {expr: EConst(CString(name))}):
              var lineNumber = MacroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case EMeta({name: name}, params):
              var fun = Reflect.field(AnnaLang, '_${name}');
              var exprs: Array<Expr> = fun(params);
              for(expr in exprs) {
                retExprs.push(expr);
              }
            case ECall(expr, args):
              var funName: String = MacroTools.getCallFunName(blockExpr);
              var args: Array<Expr> = MacroTools.getFunBody(blockExpr);
              var lineNumber: Int = MacroTools.getLineNumber(expr);
              var exprs: Array<Expr> = createPushStack(funName, args, lineNumber);
              for(expr in exprs) {
                retExprs.push(expr);
              }
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
            case ECast(expr, type):
              var exprs = walkBlock(MacroTools.buildBlock([expr]));
              for(expr in exprs) {
                retExprs.push(expr);
              }
              MacroContext.lastFunctionReturnType = MacroTools.getType(type);
            case _:
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

  private static function createPushStack(funName: String, args: Array<Expr>, lineNumber: Int):Array<Expr> {
    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    var currentFunStr: String = MacroContext.currentVar;
    var retVal: Array<Expr> = [];
    var types: Array<String> = [];
    var funArgs: Array<String> = [];
    var argCounter: Int = 0;
    for(arg in args) {
      switch(arg.expr) {
        case ECall(_, _):
          var argString = '__${funName}_${argCounter} = ${printer.printExpr(arg)};';
          arg = Macros.haxeToExpr(argString);
          var exprs: Array<Expr> = walkBlock(MacroTools.buildBlock([arg]));
          for(expr in exprs) {
            retVal.push(expr);
          }

          types.push(getType(StringTools.replace(MacroContext.lastFunctionReturnType, '.', '_')));
          funArgs.push('@tuple[@atom"var", "__${funName}_${argCounter}"]');
        case _:
          var typeAndValue = MacroTools.getTypeAndValue(arg);
          var type: String = getTypeForVar(typeAndValue, arg);
          type = StringTools.replace(type, '.', '_');
          types.push(type);
          funArgs.push(typeAndValue.value);
      }
      argCounter++;
    }
    var fqFunName = '${funName}_${types.join("_")}';

    var frags: Array<String> = fqFunName.split('.');
    fqFunName = frags.pop();
    var moduleName: String = frags.join('.');
    if(moduleName == "") {
      var moduleDef: ModuleDef = MacroContext.currentModuleDef;
      moduleName = moduleDef.moduleName;
    }
    var module: ModuleDef = MacroContext.declaredClasses.get(moduleName);
    var declaredFunctions = module.declaredFunctions;

    var funDef: Dynamic = declaredFunctions.get(fqFunName);
    if(funDef == null) {
      if(MacroContext.lastFunctionReturnType == "AnonFunction") {
        var haxeStr: String = '${currentFunStr}.push(new vm.AnonymousFunction(@atom"${funName}", @list [${funArgs.join(", ")}], @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${lineNumber}))';
        retVal.push(Macros.haxeToExpr(haxeStr));
        return retVal;
      } else {
        throw new ParsingException('AnnaLang: Function ${moduleName}.${fqFunName} not found.');
      }
    } else {
      MacroContext.lastFunctionReturnType = funDef[0].funReturnTypes[0];
      var haxeStr: String = '${currentFunStr}.push(new vm.PushStack(@atom "${module.moduleName}", @atom "${fqFunName}", @list [${funArgs.join(", ")}], @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${lineNumber}))';
      retVal.push(Macros.haxeToExpr(haxeStr));
      return retVal;
    }
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
    defineFunction(params);
    return macro {};
  }

  private static inline function defineFunction(params: Expr):Dynamic {
    var funName: String = MacroTools.getCallFunName(params);
    var allTypes: Dynamic = MacroTools.getArgTypesAndReturnTypes(params);
    var funArgsTypes: Array<Dynamic> = allTypes.argTypes;
    var types: Array<String> = [];
    for(argType in funArgsTypes) {
      var strType: String = MacroTools.resolveType(Macros.haxeToExpr(argType.type));
      var r = ~/[A-Za-z]*<|>/g;
      strType = r.replace(strType, '');
      types.push(getType(strType));
      argType.type = strType;
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
      funBody: funBody,
      allTypes: allTypes
    };
    funBodies.push(def);
    MacroContext.declaredFunctions.set(internalFunctionName, funBodies);
    return def;
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

  public static function _native(params: Expr):Array<Expr> {
    var funName: String = MacroContext.currentVar;
    var moduleName: String = MacroTools.getModuleName(params);
    moduleName = getAlias(moduleName);
    var invokeFunName = MacroTools.getFunctionName(params);
    var args = MacroTools.getFunBody(params);
    var retVal: Array<Expr> = [];
    var strArgs: Array<String> = [];
    var argCounter: Int = 0;
    for(arg in args) {
      switch(arg.expr) {
        case ECall(_, _):
          var argString = '__${invokeFunName}_${argCounter} = ${printer.printExpr(arg)};';
          arg = Macros.haxeToExpr(argString);
          var exprs: Array<Expr> = walkBlock(MacroTools.buildBlock([arg]));
          for(expr in exprs) {
            retVal.push(expr);
          }

          strArgs.push('@tuple[@atom"var", "__${invokeFunName}_${argCounter}"]');
        case _:
          var typeAndValue = MacroTools.getTypeAndValue(arg);
          strArgs.push(typeAndValue.value);
      }
      argCounter++;
    }
    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;

    var invokeClass: TypeDefinition = createOperationClass(moduleName, invokeFunName, strArgs);

    var haxeString = '${funName}.push(new vm.${invokeClass.name}(${moduleName}.${invokeFunName}, @list[${strArgs.join(', ')}],
      @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${MacroTools.getLineNumber(params)}))';
    retVal.push(Macros.haxeToExpr(haxeString));
    return retVal;
  }

  private static function createOperationClass(moduleName: String, invokeFunName: String, strArgs: Array<String>): TypeDefinition {
    var className = 'InvokeFunction_${StringTools.replace(moduleName, '.', '_')}_${StringTools.replace(invokeFunName, '.', '_')}';

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
          };
          if(Std.is(_arg${counter}, Atom)) {
            var strAtom: String = Atom.to_s(_arg${counter});
            var frags = strAtom.split(".");
            if(frags.length > 1) {
              var fun = frags.pop();
              var module = frags.join(".");
              var fn = Classes.getFunction(lang.AtomSupport.atom(module), lang.AtomSupport.atom(fun));
              if(fn != null) {
                _arg${counter} = fn;
              }
            }
          }
';
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
    MacroContext.lastFunctionReturnType = MacroTools.resolveType(expr);

    if(declaredFunctions.get(className) == null) {
      var assignReturnVar: Expr = null;
      if(MacroContext.lastFunctionReturnType == "Int" || MacroContext.lastFunctionReturnType == "Float") {
        assignReturnVar = macro scope.set("$$$", retVal);
        MacroContext.lastFunctionReturnType = "Number";
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

  public static function _fn(params: Expr): Array<Expr> {
    MacroContext.lastFunctionReturnType = "AnonFunction";
    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    switch(params.expr) {
      case EBlock(exprs):
        var counter: Int = 0;
        var anonFunctionName: String = "_" + haxe.crypto.Sha256.encode('${Math.random()}');
        var defined = null;
        for(expr in exprs) {
          var typesAndBody: Array<Dynamic> = switch(expr.expr) {
            case EParenthesis({expr: EBinop(OpArrow, types, body)}):
              var typesStr: String = printer.printExpr(types);
              [typesStr.substr(1, typesStr.length - 2), body];
            case _:
              throw new ParsingException("AnnaLang: Expected parenthesis");
          }
          var haxeStr: String = '${anonFunctionName}(${typesAndBody[0]}, ${printer.printExpr(typesAndBody[1])});';
          var expr = Macros.haxeToExpr(haxeStr);
          defined = defineFunction(expr);
        }
        var haxeStr: String = 'ops.push(new vm.DeclareAnonFunction(@atom "${currentModuleStr}.${defined.internalFunctionName}", @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${MacroTools.getLineNumber(params)}))';
        return [Macros.haxeToExpr(haxeStr)];
      case _:
       throw new ParsingException("AnnaLang: Expected block");
    }
  }

  #end

}