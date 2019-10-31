package lang.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
#if macro
import lang.macros.Fn;
import lang.macros.Native;
import lang.macros.Alias;
import lang.macros.Def;
#end
using haxe.macro.Tools;
import haxe.macro.Expr;

class AnnaLang {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  private static var uniqueId: Int = 0;

  #if macro
  private static var keywordMap: Map<String, Expr->Array<Expr>> =
  {
    keywordMap = new Map<String, Expr->Array<Expr>>();
    keywordMap.set("fn", lang.macros.Fn.gen);
    keywordMap.set("native", lang.macros.Native.gen);
    keywordMap.set("alias", lang.macros.Alias.gen);
    keywordMap.set("def", lang.macros.Def.gen);
    keywordMap.set("=", lang.macros.Match.gen);
    keywordMap;
  }
  #end

  macro public static function init(): Array<Field> {
    MacroContext.declaredClasses = new Map<String, ModuleDef>();
    return [];
  }

  macro public static function defType(name: Expr, body: Expr): Array<Field> {
    var cls: TypeDefinition = macro class NoClass extends vm.AbstractCustomType {
      public function new(arg: Dynamic) {
        if(arg == null) {
          return;
        }
        variables = new Map<String, String>();
        for(field in Reflect.fields(arg)) {
          var valueToAssign = Reflect.field(arg, field);
          var tuple: Tuple = lang.EitherSupport.getValue(valueToAssign);
          var retVal: Dynamic = arg;
          if(Std.is(tuple, Tuple)) {
            var argArray = tuple.asArray();
            if(argArray.length == 2) {
              var elem1 = argArray[0];
              var elem2 = argArray[1];
              retVal = switch(cast(lang.EitherSupport.getValue(elem1), Atom)) {
                case {value: 'var'}:
                  variables.set(field, lang.EitherSupport.getValue(elem2));
                  null;
                case _:
                  elem2;
              }
            }
          }
          Reflect.setField(this, field, valueToAssign);
        }
      }
    };
    var fields: Array<Field> = [];
    var exprs: Array<Expr> = [];
    switch(body.expr) {
      case EBlock(block):
        for(expression in block) {
          switch(expression.expr) {
            case EVars([{expr: expr, name: name, type: type}]):
              if(expr != null) {
                switch(expr.expr) {
                  case EBinop(OpMod, e, params):
                    expr = createCustomType(e, params);
                  case e:
                    var typeAndValue: Dynamic = MacroTools.getTypeAndValue(expr);
                    expr = Macros.haxeToExpr(typeAndValue.rawValue);
                }
              }
              var field: Field = {name: name, pos: Context.currentPos(), kind: FVar(type, expr), access: [APublic]};
              fields.push(field);
              exprs.push(expression);
            case _:
              throw "AnnaLang: Unexpected code. You can only define var types. For Example: `var name: String;` or `var ellie: Bear;`";
          }
        }
      case _:
        throw "AnnaLang: Unexpected code. You can only define var types. For Example: `var name: String;` or `var ellie: Bear;`";
    }
    cls.fields = cls.fields.concat(fields);

    var className: String = printer.printExpr(name);

    var str: String = 'return new ${className}(args)';
    var createBodyExpr = Macros.haxeToExpr(str);

    var createField: Field = {
      name: 'create',
      pos: Context.currentPos(),
      kind: FFun({args: [{name: 'args', type: MacroTools.buildType('Dynamic')}], expr: createBodyExpr, ret: MacroTools.buildType(className)}),
      access: [APublic, AStatic, AInline]
    };
    cls.fields.push(createField);

    cls.name = className;
    applyBuildMacro(cls);
    Context.defineType(cls);
    MacroLogger.log(printer.printTypeDefinition(cls));
    return [];
  }

  #if macro
  public static inline function createCustomType(type: Expr, params: Expr): Expr {
    var typeAndValue: Dynamic = MacroTools.getTypeAndValue(params);
    typeAndValue.type = printer.printExpr(type);
    var str: String = '${typeAndValue.type}.create(${typeAndValue.rawValue})';
    var expr = Macros.haxeToExpr(str);
    return expr;
  }
  #end

  macro public static function compile(): Array<Field> {
    for(className in MacroContext.declaredClasses.keys()) {
      var moduleDef: ModuleDef = MacroContext.declaredClasses.get(className);
      MacroContext.currentModuleDef = moduleDef;
      MacroContext.aliases = moduleDef.aliases;
      var cls = MacroTools.createClass(className);
      MacroContext.currentModule = cls;
      MacroContext.declaredFunctions = moduleDef.declaredFunctions;
      applyBuildMacro(cls);

      var definedFunctions: Map<String, String> = new Map<String, String>();
      var apiMap: Map<String, Array<Dynamic>> = new Map<String, Array<Dynamic>>();

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

            for(argType in cast(funDef.funArgsTypes, Array<Dynamic>)) {
              MacroContext.varTypesInScope.set(argType.name, argType.type);
            }

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
            apiMap.set(funDef.name, funDefs);

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
            var argNameCounter: Int = 0;
            for(funArgsType in funArgsTypes) {
              var argName: String = '_${argNameCounter++}';
              funArgs.push({name: argName, type: MacroTools.buildType(funArgsType.type)});
              var haxeStr: String = '';
              if(funArgsType.pattern != funArgsType.name) {
                var pattern: String = funArgsType.pattern;
                if(funArgsType.type == "String") {
                  var ereg: EReg = ~/"|'.*"|'.*=>/;
                  if(!ereg.match(pattern)) {
                    pattern = '"${pattern}"';
                  }
                }
                haxeStr = 'var match: Map<String, Dynamic> = lang.macros.PatternMatch.match(${pattern}, ${argName});';
              }
              patternMatches.push(haxeStr);
            }
            funArgs.push({name: "____scopeVariables", type: MacroTools.buildType('Map<String, Dynamic>')});
            if(field == null) {
              field = MacroTools.buildPublicFunction(internalFunctionName, funArgs, returnType);
            }
            var makeIfBlock: Bool = false;
            if(patternMatches.length > 0) {
              var matchStatements: Array<String> = [];
              for(pattenMatch in patternMatches) {
                if(pattenMatch != "") {
                  matchStatements.push('match != null');
                }
              }
              patternTest += patternMatches.join("\n");
              if(matchStatements.length > 0) {
                patternTest += 'if(${matchStatements.join(" && ")}) {';
                patternTest += '__updateScope(match, ____scopeVariables);';
                makeIfBlock = true;
              }
            }
            patternTest += 'return _${internalFunctionName}_${index};';
            if(makeIfBlock) {
              patternTest += "}";
            }
            index++;
          }
          patternTest += 'return null;';
          var patternExpr: Expr = Macros.haxeToExpr(patternTest);
          MacroTools.assignFunBody(field, patternExpr);
          patternTest = '';
          MacroTools.addFieldToClass(MacroContext.currentModule, field);
        }
      }

      var funArgs: Array<FunctionArg> = [];
      funArgs.push({name: 'match', type: MacroTools.buildType("Map<String, Dynamic>")});
      funArgs.push({name: 'scope', type: MacroTools.buildType("Map<String, Dynamic>")});
      var field = MacroTools.buildPrivateFunction('__updateScope', funArgs, MacroTools.buildType("Void"));
      var body: Expr = macro {
        for(key in match.keys()) {
          scope.set(key, match.get(key));
        }
      }

      MacroTools.assignFunBody(field, body);
      MacroTools.addFieldToClass(MacroContext.currentModule, field);

      //finally add the api definition function
      for(funKey in apiMap.keys()) {
        var funDefs: Array<Dynamic> = apiMap.get(funKey);
        var allDefsStr: Array<String> = [];
        for(funDef in funDefs) {
          var exprStr = 'Atom.create("${funDef.internalFunctionName}")';
          allDefsStr.remove(exprStr);
          allDefsStr.push(exprStr);
        }
        var functionAtoms: Expr = Macros.haxeToExpr('[${allDefsStr.join(', ')}]');

        var varType: ComplexType = MacroTools.buildType('Array<Atom>');
        field = MacroTools.buildPublicVar('__api_${funKey}', varType, [functionAtoms]);
        MacroTools.addFieldToClass(MacroContext.currentModule, field);
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
  private static inline function __updateScope(match:Map<String, Dynamic>, scope:Map<String, Dynamic>):Void {
    for (key in match.keys()) {
      scope.set(key, match.get(key));
    };
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
    // For some unknown reason, we need to define a garbage function or haxe will crash :: eye_roll ::
    Def.gen(Macros.haxeToExpr('alkdsjfkldsjf_ldkfj34893_dlksfj([Atom], {
      @_"ok";
    });'));
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
              if(fun == null) {
                fun = keywordMap.get(name);
              }
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

  public static function walkBlock(expr: Expr): Array<Expr> {
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
              if(fun == null) {
                fun = keywordMap.get(name);
              }
              var exprs: Array<Expr> = fun(params);
              for(expr in exprs) {
                retExprs.push(expr);
              }
            case ECall(expr, args):
              var funName: String = MacroTools.getCallFunName(blockExpr);
              var args: Array<Expr> = MacroTools.getFunBody(blockExpr);
              var lineNumber: Int = MacroTools.getLineNumber(expr);
              var pushStackArgs: Array<Expr> = [];
              for(i in 0...args.length) {
                var arg = args[i];
                switch(arg.expr) {
                  case EMeta({name: 'fn'}, expr):
                    var exprs = keywordMap.get("fn")(expr);
                    retExprs = retExprs.concat(exprs);
                    var varName: String = '__${funName}';
                    var exprs = keywordMap.get("=")(Macros.haxeToExpr(varName));
                    retExprs = retExprs.concat(exprs);
                    pushStackArgs.push({expr: EConst(CIdent(varName)), pos: Context.currentPos()});
                  case _:
                    pushStackArgs.push(arg);
                }
              }
              var exprs: Array<Expr> = createPushStack(funName, pushStackArgs, lineNumber);
              for(expr in exprs) {
                retExprs.push(expr);
              }
            case EBinop(OpAssign, left, right):
              var lineNumber = MacroTools.getLineNumber(right);
              var exprs = walkBlock(MacroTools.buildBlock([right]));
              for(expr in exprs) {
                retExprs.push(expr);
              }
              var assignOp: Array<Expr> = keywordMap.get("=")(left);
              retExprs.push(assignOp[0]);
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
              var strType: String = MacroTools.getType(type);
              var aliasType: String = MacroContext.aliases.get(strType);
              if(aliasType == null) {
                aliasType = strType;
              }
              MacroContext.lastFunctionReturnType = aliasType;
            case EBinop(OpMod, type, params):
              var lineNumber = MacroTools.getLineNumber(blockExpr);
              MacroContext.lastFunctionReturnType = MacroTools.getIdent(type);
              var custom:Expr = createCustomType(type, params);
              var args: String = '@tuple [@atom "const", ${printer.printExpr(custom)}]';
              var assignOp: Expr = putIntoScope(args, lineNumber);
              retExprs.push(assignOp);
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

  public static function applyBuildMacro(cls: TypeDefinition):Void {
    var metaConst = MacroTools.buildConst(CIdent('lang.macros.Macros'));
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
          arg = lang.macros.Macros.haxeToExpr(argString);
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
    var spacer: String = '_';
    if(types.length == 0) {
     spacer = '';
    }
    var fqFunName = makeFqFunName(funName, types);

    var frags: Array<String> = fqFunName.split('.');
    fqFunName = frags.pop();
    var moduleName: String = frags.join('.');
    if(moduleName == "") {
      var moduleDef: ModuleDef = MacroContext.currentModuleDef;
      moduleName = moduleDef.moduleName;
    }
    var module: ModuleDef = MacroContext.declaredClasses.get(moduleName);
    if(module == null) {
      throw new FunctionClauseNotFound('AnnaLang: Function ${funName}() not found.');
    }
    var declaredFunctions = module.declaredFunctions;

    var funDef: Dynamic = declaredFunctions.get(fqFunName);
    if(funDef == null) {
      var varTypeInScope: String = MacroContext.varTypesInScope.get(funName);
      if(varTypeInScope == 'vm_Function') {
        var haxeStr: String = '${currentFunStr}.push(new vm.AnonymousFunction(@atom"${funName}", @list [${funArgs.join(", ")}], @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${lineNumber}))';
        retVal.push(lang.macros.Macros.haxeToExpr(haxeStr));
        return retVal;
      }
      throw 'Function ${funName} at line ${lineNumber} not found';
    } else {
      MacroContext.lastFunctionReturnType = funDef[0].funReturnTypes[0];
      var haxeStr: String = '${currentFunStr}.push(new vm.PushStack(@atom "${module.moduleName}", @atom "${fqFunName}", @list [${funArgs.join(", ")}], @atom "${currentModuleStr}", @atom "${MacroContext.currentFunction}", ${lineNumber}))';
      retVal.push(lang.macros.Macros.haxeToExpr(haxeStr));
      return retVal;
    }
  }

  private static function getTypeForVar(typeAndValue: Dynamic, arg: Expr):String {
    return switch(arg.expr) {
      case EConst(CIdent(varName)):
        if(typeAndValue.rawValue == "vm_Function") {
          return "vm_Function";
        }
        var type = MacroContext.varTypesInScope.get(varName);
        getType(type);
      case _:
        getType(typeAndValue.type);
    }
  }

  public static function getType(type: String):String {
    return switch(type) {
      case "Int" | "Float":
        "Number";
      case null:
        getAlias(MacroContext.lastFunctionReturnType);
      case _:
        type;
    }
  }
  
  private static function createPutIntoScope(expr: Expr, lineNumber: Int):Expr {
    var moduleName: String = MacroTools.getModuleName(expr);
    moduleName = getAlias(moduleName);

    var args = MacroTools.getFunBody(expr);
    var strArgs: Array<String> = [];
    for(arg in args) {
      var typeAndValue = MacroTools.getTypeAndValue(arg);
      strArgs.push(typeAndValue.value);
    }
    MacroContext.lastFunctionReturnType = getAnnaVarConstType(lang.macros.Macros.haxeToExpr(strArgs.join(";")));
    return putIntoScope(strArgs.join(", "), lineNumber);
  }

  private static function putIntoScope(args: String, lineNumber: Int): Expr {
    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    var currentFunction: String = MacroContext.currentFunction;
    var currentFunStr: String = MacroContext.currentVar;

    var haxeStr: String = '${currentFunStr}.push(new vm.PutInScope(${args}, @atom "${currentModuleStr}", @atom "${currentFunction}", ${lineNumber}));';
    return lang.macros.Macros.haxeToExpr(haxeStr);
  }

  public static function __(params: Expr):Expr {
    var haxeStr: String = '@atom"${MacroTools.extractFullFunCall(params)[0]}";';
    return createPutIntoScope(lang.macros.Macros.haxeToExpr(haxeStr), MacroTools.getLineNumber(params));
  }

  public static function getAlias(str: String):String {
    return switch(MacroContext.aliases.get(str)) {
      case null:
        str;
      case val:
        val;
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

  public static inline function makeFqFunName(funName: String, types: Array<String>):String {
    var spacer: String = '_';
    if(types.length == 0) {
     spacer = '';
    }
    return '${funName}${spacer}${sanitizeArgTypeNames(types)}';
  }

  public static function sanitizeArgTypeNames(types: Array<String>):String {
    return StringTools.replace(types.join("_"), ".", "_");
  }
  #end

}