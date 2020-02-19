package lang.macros;

import util.StringUtil;
import lang.macros.MacroTools;
import hscript.Macro;
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

class AnnaLang {

  private static var keywordMap: Map<String, AnnaLang->Expr->Array<Expr>> =
  {
    keywordMap = new Map<String, AnnaLang->Expr->Array<Expr>>();
    keywordMap.set("fn", lang.macros.Fn.gen);
    keywordMap.set("native", lang.macros.Native.gen);
    keywordMap.set("alias", lang.macros.Alias.gen);
    keywordMap.set("def", lang.macros.Def.gen);
    keywordMap.set("const", lang.macros.Const.gen);
    keywordMap.set("impl", lang.macros.Impl.gen);
    keywordMap.set("=", lang.macros.Match.gen);
    keywordMap;
  }

  public var parser: ParserPlus = {
    var parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  public static var annaLangForMacro: AnnaLang = new AnnaLang();
  public var printer: Printer = new Printer();

  public var macroContext: MacroContext;
  public var macroTools: MacroTools;
  public var macros: Macros;

  // This is for the interpreter
  public var lang: Dynamic;

  public function new() {
    macroContext = new MacroContext(this);
    macros = new Macros(this);
    macroTools = new MacroTools(this);
  }

  macro public static function init(): Array<Field> {
    MacroLogger.init();
    return AnnaLang.persistClassFields();
  }

  macro public static function defapi(name:Expr, body:Expr):Array<Field> {
    return annaLangForMacro.defApi(name, body);
  }

  public function defApi(name: Expr, body: Expr): Array<Field> {
    var interfaceName: String = macroTools.getIdent(name);
    var moduleDef = new ModuleDef(interfaceName);
    switch(body.expr) {
      case EBlock(exprs):
        for(blockExpr in exprs) {
          switch(blockExpr.expr) {
            case EMeta({name: 'def'}, params):
              var def: Dynamic = Def.defineFunction(this, params);
              var arrayDef: Array<Dynamic> = moduleDef.declaredFunctions.get(def.internalFunctionName);
              if(arrayDef == null) {
                arrayDef = [];
              }
              arrayDef.push(def);
              moduleDef.declaredFunctions.set(def.internalFunctionName, arrayDef);
            case e:
              MacroLogger.log(e, 'e');
              throw "AnnaLang defApi Prewalk: Not sure what to do here yet";
          }
        }
      case e:
        MacroLogger.log(e, 'e');
        throw "AnnaLang defApi Prewalk: Not sure what to do here yet";
    }
    macroContext.declaredInterfaces.set(interfaceName, moduleDef);

    return AnnaLang.persistClassFields();
  }

  macro public static function deftype(name: Expr, body: Expr): Array<Field> {
    return annaLangForMacro.defType(name, body);
  }

  public function defType(name: Expr, body: Expr): Array<Field> {
    var cls: TypeDefinition = macro class NoClass extends lang.AbstractCustomType {
      public function new(arg: Dynamic) {
        if(arg == null) {
          return;
        }

        var variablesInScope = vm.Process.self().processStack.getVariablesInScope();
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
                  null;
                case _:
                  elem2;
              }
            }
          }
          Reflect.setField(this, field, valueToAssign);
        }
      }

      override public function clone(): lang.AbstractCustomType {
        var fields: Array<String> = Reflect.fields(this);
        var obj: Dynamic = {};
        for(field in fields) {
          if(field == 'variables') {
            continue;
          }
          Reflect.setField(obj, field, Reflect.field(this, field));
        }
        return create(obj);
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
                    var typeAndValue: Dynamic = macroTools.getTypeAndValue(expr);
                    expr = macros.haxeToExpr(typeAndValue.rawValue);
                }
              }
              var field: Field = {name: name, pos: macroContext.currentPos(), kind: FVar(type, expr), access: [APublic]};
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
    var createBodyExpr = macros.haxeToExpr(str);

    var createField: Field = {
      name: 'create',
      pos: macroContext.currentPos(),
      kind: FFun({args: [{name: 'args', type: macroTools.buildType('Dynamic')}], expr: createBodyExpr, ret: macroTools.buildType(className)}),
      access: [APublic, AStatic, AInline]
    };
    cls.fields.push(createField);

    cls.name = className;
    Helpers.applyBuildMacro(this, cls);
    macroContext.defineType(cls);
    MacroLogger.log(printer.printTypeDefinition(cls));
    return AnnaLang.persistClassFields();
  }

  private inline function createCustomType(type: Expr, params: Expr): Expr {
    var typeAndValue: Dynamic = macroTools.getCustomTypeAndValue(params);
    typeAndValue.type = printer.printExpr(type);
    var str: String = '${typeAndValue.type}.create(${typeAndValue.rawValue})';
    var expr = macros.haxeToExpr(str);
    return expr;
  }

  macro public static function do_compile(): Array<Field> {
    return annaLangForMacro.compile();
  }

  public function compile(): Array<Field> {
    for(className in macroContext.declaredClasses.keys()) {
      var moduleDef: ModuleDef = macroContext.declaredClasses.get(className);
      macroContext.currentModuleDef = moduleDef;
      macroContext.aliases = moduleDef.aliases;
      var cls = macroTools.createClass(className);
      macroContext.currentModule = cls;
      Helpers.applyBuildMacro(this, cls);

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
            macroContext.currentFunction = funDef.name;
            macroContext.currentFunctionArgTypes = [];
            macroContext.varTypesInScope = new VarTypesInScope();
            macroContext.lastFunctionReturnType = "";

            MacroLogger.log(funDef.funArgsTypes, 'funDef.funArgsTypes');
            for(argType in cast(funDef.funArgsTypes, Array<Dynamic>)) {
              var types: Array<String> = macroContext.varTypesInScope.getTypes(argType.name);
              macroContext.varTypesInScope.set(argType.name, argType.type);
            }

            // Actual operations this function will be doing
            var funBody = funDef.funBody;
            var body: Array<Expr> = [];
            var varName: Expr = macro var ops: Array<vm.Operation> = [];

            macroContext.currentVar = 'ops';
            body.push(varName);

            var funBodies: Array<Dynamic> = cast(funDef.funBody, Array<Dynamic>);
            for(bodyExpr in funBodies) {
              if(funDef.varTypesInScope != null) {
                macroContext.varTypesInScope.join(funDef.varTypesInScope);
              }
              var walkBody = walkBlock(bodyExpr);
              for(expr in walkBody) {
                body.push(expr);
              }
            }
            var ret = macroTools.buildConst(CIdent('ops'));
            body.push(ret);

            var internalFunctionName: String = funDef.internalFunctionName;
            if(prevFunctionName == internalFunctionName) {
              index++;
            } else {
              index = 0;
            }
            prevFunctionName = internalFunctionName;
            var varType: ComplexType = macroTools.buildType('Array<vm.Operation>');
            var pubVar = macroTools.buildPublicVar('_${internalFunctionName}_${index}', varType, body);
            macroTools.addFieldToClass(macroContext.currentModule, pubVar);

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
            var varType: ComplexType = macroTools.buildType('Array<String>');
            var expr = macro var args: Array<String> = [];
            exprs.push(expr);
            for(funArgs in funArgsTypes) {
              if(funArgs.isPatternVar) {
                continue;
              }
              var haxeExpr = macros.haxeToExpr('args.push("${funArgs.name}");');
              exprs.push(haxeExpr);
            }
            var ret = macroTools.buildConst(CIdent('args'));
            exprs.push(ret);
            var argFun = macroTools.buildPublicVar('___${funDef.name}_${funDef.argTypes}_${index}_args', varType, exprs);
            macroTools.addFieldToClass(macroContext.currentModule, argFun);
          }
        }

        validateImplementedInterfaces(moduleDef);

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
            var returnType: ComplexType = macroTools.buildType('Array<vm.Operation>');
            var funArgs: Array<FunctionArg> = [];
            var patternMatches: Array<String> = [];
            var argNameCounter: Int = 0;
            var matchCount: Int = 0;

            for(funArgsType in funArgsTypes) {
              if(funArgsType.isPatternVar) {
                continue;
              }
              var argName: String = '_${argNameCounter++}';
              funArgs.push({name: argName, type: macroTools.buildType(funArgsType.type)});
              var haxeStr: String = '';
              if(funArgsType.pattern != funArgsType.name) {
                var pattern: String = funArgsType.pattern;
                if(funArgsType.type == "String") {
                  var ereg: EReg = ~/"|'.*"|'.*=>/;
                  if(!ereg.match(pattern)) {
                    pattern = '"${pattern}"';
                  }
                }
                var patternExpr = PatternMatch.match(this, macros.haxeToExpr(pattern), macros.haxeToExpr(argName));
                MacroLogger.logExpr(patternExpr, 'patternExpr');
                haxeStr = 'var match${matchCount}: Map<String, Dynamic> = ${printer.printExpr(patternExpr)};';
                matchCount++;
              } else {
                haxeStr = 'var match${matchCount}: Map<String, Dynamic> = {
                  var scope:haxe.ds.StringMap<Dynamic> = new haxe.ds.StringMap();
                  scope.set("${funArgsType.name}", ${argName});
                  scope;
                };';
                matchCount++;
              }
              patternMatches.push(haxeStr);
            }
            funArgs.push({name: "____scopeVariables", type: macroTools.buildType('Map<String, Dynamic>')});
            if(field == null) {
              field = macroTools.buildPublicFunction(internalFunctionName, funArgs, returnType);
            }
            var makeIfBlock: Bool = false;
            if(patternMatches.length > 0) {
              var matchStatements: Array<String> = [];
              var matchCount: Int = 0;
              for(pattenMatch in patternMatches) {
                if(pattenMatch != "") {
                  matchStatements.push('match${matchCount++} != null');
                }
              }
              patternTest += patternMatches.join("\n");
              if(matchStatements.length > 0) {
                patternTest += 'if(${matchStatements.join(" && ")}) {';
                for(i in 0...matchStatements.length) {
                  patternTest += '__updateScope(match${i}, ____scopeVariables);';
                }
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
          var patternExpr: Expr = macros.haxeToExpr(patternTest);
          macroTools.assignFunBody(field, patternExpr);
          patternTest = '';
          macroTools.addFieldToClass(macroContext.currentModule, field);
        }
      }

      var funArgs: Array<FunctionArg> = [];
      funArgs.push({name: 'match', type: macroTools.buildType("Map<String, Dynamic>")});
      funArgs.push({name: 'scope', type: macroTools.buildType("Map<String, Dynamic>")});
      var field = macroTools.buildPrivateFunction('__updateScope', funArgs, macroTools.buildType("Void"));
      var body: Expr = macro {
        for(key in match.keys()) {
          scope.set(key, match.get(key));
        }
      }

      macroTools.assignFunBody(field, body);
      macroTools.addFieldToClass(macroContext.currentModule, field);

      //finally add the api definition function
      for(funKey in apiMap.keys()) {
        var funDefs: Array<Dynamic> = apiMap.get(funKey);
        var allDefsStr: Array<String> = [];
        for(funDef in funDefs) {
          var exprStr = 'Atom.create("${funDef.internalFunctionName}")';
          allDefsStr.remove(exprStr);
          allDefsStr.push(exprStr);
        }
        var functionAtoms: Expr = macros.haxeToExpr('[${allDefsStr.join(', ')}]');

        var varType: ComplexType = macroTools.buildType('Array<Atom>');
        field = macroTools.buildPublicVar('__api_${funKey}', varType, [functionAtoms]);
        macroTools.addFieldToClass(macroContext.currentModule, field);
      }

      macroContext.defineType(cls);

      MacroLogger.log("==================");
      MacroLogger.log('Fields for ${className}');
      MacroLogger.log('------------------');
      MacroLogger.printFields(cls.fields);
      MacroLogger.log("------------------");
    }

    var defineCodeBody: Array<Expr> = [];
    for(moduleDef in macroContext.declaredClasses) {
      var associatedIface = macroContext.associatedInterfaces.get(moduleDef.moduleName);
      var expr: Expr = null;
      var moduleNameExpr = macroTools.buildConst(CString(moduleDef.moduleName));
      if(associatedIface != null) {
        expr = macros.haxeToExpr('vm.Classes.define(Atom.create("${associatedIface}"), ${moduleDef.moduleName})');
        defineCodeBody.push(expr);
      }
      expr = macros.haxeToExpr('vm.Classes.define(Atom.create("${moduleDef.moduleName}"), ${moduleDef.moduleName})');
      defineCodeBody.push(expr);

      expr = macro var moduleDef: lang.macros.ModuleDef = new lang.macros.ModuleDef("$e{moduleNameExpr}");
      defineCodeBody.push(expr);

      for(aliasKey in moduleDef.aliases.keys()) {
        var aliasValue: String = moduleDef.aliases.get(aliasKey);
        expr = macros.haxeToExpr('moduleDef.aliases.set("${aliasKey}", "${aliasValue}");');
        defineCodeBody.push(expr);
      }

      for(constantsKey in moduleDef.constants.keys()) {
        var constValue: String = moduleDef.constants.get(constantsKey);
        expr = macros.haxeToExpr('moduleDef.constants.set("${constantsKey}", "${constValue}");');
        defineCodeBody.push(expr);
      }

      for(declaredFunctionsKey in moduleDef.declaredFunctions.keys()) {
        var declaredFunctionsValue: Array<Dynamic> = moduleDef.declaredFunctions.get(declaredFunctionsKey);
        var genFunctionStrs: Array<String> = [];

        expr = macro var decFuns: Array<Dynamic> = [];
        defineCodeBody.push(expr);

        for(declaredFunction in declaredFunctionsValue) {
          expr = macro var decFun: Dynamic = {};
          defineCodeBody.push(expr);

          var fields: Array<String> = Reflect.fields(declaredFunction);
          for(field in fields) {
            if(field == 'funBody' || field == 'allTypes' || field == 'funArgsTypes' || field == 'varTypesInScope') {
              continue;
            } else if(field == 'funReturnTypes') {
              var fieldValue = Reflect.field(declaredFunction, field);
              expr = macros.haxeToExpr('decFun.${field} = ${fieldValue};');
              defineCodeBody.push(expr);
            } else {
              var fieldValue = Reflect.field(declaredFunction, field);
              expr = macros.haxeToExpr('decFun.${field} = "${fieldValue}";');
              defineCodeBody.push(expr);
            }
          }

          expr = macro decFuns.push(decFun);
          defineCodeBody.push(expr);
        }
        expr = macros.haxeToExpr('moduleDef.declaredFunctions.set("${declaredFunctionsKey}", decFuns)');
        defineCodeBody.push(expr);
      }

      expr = macros.haxeToExpr('annaLang.macroContext.declaredClasses.set("${moduleDef.moduleName}", moduleDef)');
      defineCodeBody.push(expr);
    }
    defineCodeBody.push(macro {return Atom.create("ok"); });
    var defineCodeField: Field = macroTools.buildPublicStaticFunction("defineCode", [], macroTools.buildType("Atom"));
    var field: Field = macroTools.assignFunBody(defineCodeField, macroTools.buildBlock(defineCodeBody));

    var classFields: Array<Field> = AnnaLang.persistClassFields();
    classFields.push(field);

    var initBody: Expr = macro new lang.macros.AnnaLang();
    field = macroTools.buildPublicStaticVar("annaLang", macroTools.buildType("lang.macros.AnnaLang"), [initBody]);
    classFields.push(field);
    MacroLogger.log("===========================================================", '"==========================================================="');
    MacroLogger.printFields(classFields);

    MacroLogger.close();
    return classFields;
  }

  macro public static function set_iface(ifaceName: Expr, implName: Expr): Array<Field> {
    return annaLangForMacro.setIface(ifaceName, implName);
  }

  public function setIface(ifaceName: Expr, implName: Expr): Array<Field> {
    var iface: String = macroTools.getIdent(ifaceName);
    var impl: String = macroTools.getIdent(implName);
    macroContext.associatedInterfaces.set(impl, iface);
    return AnnaLang.persistClassFields();
  }

  macro public static function defmodule(name: Expr, body: Expr): Array<Field> {
    return annaLangForMacro.defCls(name, body);
  }

  public function defCls(name: Expr, body: Expr): Array<Field> {
    MacroLogger.log('==============================');
    var className: String = printer.printExpr(name);
    var moduleDef: ModuleDef = new ModuleDef(className);
    initCls();
    macroContext.currentModuleDef = moduleDef;
    MacroLogger.log(className, 'name');
    MacroLogger.logExpr(body, 'bodyString');

    prewalk(body);

    Def.gen(this, { expr: ECall({ expr: EConst(CIdent('__MODULE_NAME__')),
      pos: macroContext.currentPos() },[{ expr: EArrayDecl([{ expr: EConst(CIdent('Atom')),
      pos: macroContext.currentPos() }]), pos: macroContext.currentPos() },{
      expr: EBlock([{ expr: EMeta({ name: '_', params: [], pos: macroContext.currentPos() },
      { expr: EConst(CString(className)), pos: macroContext.currentPos() }),
        pos: macroContext.currentPos() }]), pos: macroContext.currentPos() }]),
      pos: macroContext.currentPos() });

    macroContext.declaredClasses.set(className, moduleDef);
    moduleDef.aliases = macroContext.aliases;

    return AnnaLang.persistClassFields();
  }

  public static function initCls(): Void {
  }

  #if macro
  private static inline function persistClassFields():Array<Field> {
    var fields: Array<Field> = Context.getBuildFields();
    return fields;
  }
  #else
  private static inline function persistClassFields():Array<Field> {
    return [];
  }
  #end

  private function validateImplementedInterfaces(moduleDef: ModuleDef):Void {
    for(iface in moduleDef.interfaces) {
      var interfaceDef: ModuleDef = macroContext.declaredInterfaces.get(iface);
      if(interfaceDef == null) {
        throw 'AnnaLang: interface ${iface} is not defined.';
      }

      for(internalFunctionName in interfaceDef.declaredFunctions.keys()) {
        var fun = moduleDef.declaredFunctions.get(internalFunctionName);
        if(fun == null) {
          MacroLogger.log(moduleDef.declaredFunctions, 'moduleDef.declaredFunctions');
          throw 'AnnaLang: ${moduleDef.moduleName} missing interface function ${internalFunctionName} as specified in ${interfaceDef.moduleName}.';
        }
      }
    }
  }

  private function allFunctionsDefined(definedFunctions: Map<String, String>):Bool {
    for(key in macroContext.currentModuleDef.declaredFunctions.keys()) {
      if(definedFunctions.get(key) == null) {
        return false;
      }
    }
    return true;
  }

  private function getUndefinedFunctions(definedFunctions: Map<String, String>):Map<String, Array<Dynamic>> {
    var retVal = new Map<String, Array<Dynamic>>();
    for(key in macroContext.currentModuleDef.declaredFunctions.keys()) {
      if(definedFunctions.get(key) == null) {
        retVal.set(key, macroContext.currentModuleDef.declaredFunctions.get(key));
      }
    }
    return retVal;
  }

  private function prewalk(expr: Expr): Void {
    switch(expr.expr) {
      case EBlock(exprs):
        for(blockExpr in exprs) {
          switch(blockExpr.expr) {
            case EMeta({name: name}, params):
              var fun = Reflect.field(AnnaLang, '_${name}');
              if(fun == null) {
                fun = keywordMap.get(name);
              }
              fun(this, params);
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

  public function walkBlock(expr: Expr): Array<Expr> {
    var retExprs: Array<Expr> = [];
    switch(expr.expr) {
      case EBlock(exprs):
        for(blockExpr in exprs) {
          switch(blockExpr.expr) {
            case EMeta({name: '_'}, {expr: EConst(CString(name))}):
              var lineNumber = macroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case EMeta({name: name}, params):
              var fun = keywordMap.get(name);
              var exprs: Array<Expr> = fun(this, params);
              for(expr in exprs) {
                retExprs.push(expr);
              }
            case ECall({ expr: EField({ expr: EConst(CIdent(moduleName))}, funName) }, params):
              var args: Array<Expr> = macroTools.getFunBody(blockExpr);
              var lineNumber: Int = macroTools.getLineNumber(expr);
              var pushStackArgs: Array<Expr> = [];
              for(i in 0...args.length) {
                var arg = args[i];
                switch(arg.expr) {
                  case EMeta({name: 'fn'}, expr):
                    var exprs = keywordMap.get("fn")(this, expr);
                    retExprs = retExprs.concat(exprs);
                    var varName: String = '${funName}';
                    var exprs = keywordMap.get("=")(this, macros.haxeToExpr(varName));
                    retExprs = retExprs.concat(exprs);
                    pushStackArgs.push({expr: EConst(CIdent(varName)), pos: macroContext.currentPos()});
                  case _:
                    pushStackArgs.push(arg);
                }
              }
              var exprs: Array<Expr> = createPushStack(moduleName, funName, pushStackArgs, lineNumber);
              for(expr in exprs) {
                retExprs.push(expr);
              }
            case ECall(expr, args):
              var funName: String = macroTools.getCallFunName(blockExpr);
              var args: Array<Expr> = macroTools.getFunBody(blockExpr);
              var lineNumber: Int = macroTools.getLineNumber(expr);
              var pushStackArgs: Array<Expr> = [];
              for(i in 0...args.length) {
                var arg = args[i];
                switch(arg.expr) {
                  case EMeta({name: 'fn'}, expr):
                    var exprs = keywordMap.get("fn")(this, expr);
                    retExprs = retExprs.concat(exprs);
                    var varName: String = '__${funName}';
                    var exprs = keywordMap.get("=")(this, macros.haxeToExpr(varName));
                    retExprs = retExprs.concat(exprs);
                    pushStackArgs.push({expr: EConst(CIdent(varName)), pos: macroContext.currentPos()});
                  case _:
                    pushStackArgs.push(arg);
                }
              }
              var currentModule: TypeDefinition = macroContext.currentModule;
              var currentModuleStr: String = currentModule.name;

              var exprs: Array<Expr> = createPushStack(currentModuleStr, funName, pushStackArgs, lineNumber);
              for(expr in exprs) {
                retExprs.push(expr);
              }
            case EBinop(OpAssign, left, right):
              var lineNumber = macroTools.getLineNumber(right);
              var exprs = walkBlock(macroTools.buildBlock([right]));
              for(expr in exprs) {
                retExprs.push(expr);
              }
              var assignOp: Array<Expr> = keywordMap.get("=")(this, left);
              retExprs.push(assignOp[0]);
            case EConst(CString(value)) | EConst(CInt(value)) | EConst(CFloat(value)) | EConst(CIdent(value)):
              var lineNumber = macroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case EArrayDecl(values):
              var lineNumber = macroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case EBlock(values):
              var lineNumber = macroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case ECast(expr, type):
              var exprs = walkBlock(macroTools.buildBlock([expr]));
              for(expr in exprs) {
                retExprs.push(expr);
              }
              var strType: String = macroTools.getType(type);
              var aliasType: String = macroContext.aliases.get(strType);
              if(aliasType == null) {
                aliasType = strType;
              }
              macroContext.lastFunctionReturnType = aliasType;
            case EBinop(OpMod, type, params):
              var lineNumber = macroTools.getLineNumber(blockExpr);
              macroContext.lastFunctionReturnType = macroTools.getIdent(type);
              var custom:Expr = createCustomType(type, params);
              var args: String = macroTools.getConstant(printer.printExpr(custom));
              var assignOp: Expr = putIntoScope(args, lineNumber);
              retExprs.push(assignOp);
            case EBinop(OpArrow, left, {expr: EBinop(OpAssign, match, right)}):
              var lineNumber = macroTools.getLineNumber(right);
              var exprs = walkBlock(macroTools.buildBlock([right]));
              for(expr in exprs) {
                retExprs.push(expr);
              }
              var left = macros.haxeToExpr('@__stringMatch ${printer.printExpr(left)} => ${printer.printExpr(match)}');
              var assignOp: Array<Expr> = keywordMap.get("=")(this, left);
              retExprs.push(assignOp[0]);
            case EObjectDecl(values):
              var lineNumber = macroTools.getLineNumber(blockExpr);
              var assignOp: Expr = createPutIntoScope(blockExpr, lineNumber);
              retExprs.push(assignOp);
            case _:
              blockExpr;
          }
        }
      case EConst(ident):
      case EMeta({name: name}, _):
        macroContext.currentFunctionArgTypes.push(name);
      case EObjectDecl(_) | EArrayDecl(_):
      case e:
        MacroLogger.log(e, 'e');
        throw "AnnaLang: Not sure what to do here yet";
    }
    return retExprs;
  }

  private function generatePermutations(lists:Array<Array<String>>, result: Array<Array<String>>, depth: Int, current: Array<String>):Void {
    var solutions: Int = 1;
    for(i in 0...lists.length) {
      solutions *= lists[i].length;
    }
    for(i in 0...solutions) {
      var j: Int = 1;
      var items: Array<String> = [];
      for(item in lists) {
        items.push(item[Std.int(i/j) % item.length]);
        j *= item.length;
      }
      result.push(items);
    }
  }

  private function createPushStack(currentModuleStr: String, funName: String, args: Array<Expr>, lineNumber: Int):Array<Expr> {
    var moduleName: String = currentModuleStr;
    if(moduleName == "") {
      var moduleDef: ModuleDef = macroContext.currentModuleDef;
      moduleName = moduleDef.moduleName;
    }
    var module: ModuleDef = macroContext.declaredClasses.get(moduleName);
    if(module == null) {
      module = macroContext.declaredInterfaces.get(moduleName);
    }

    var fqFunNameTypeMap: Map<String, String> = new Map();
    var types: Array<Array<String>> = [];
    var funArgs: Array<String> = [];
    var argCounter: Int = 0;
    var retVal: Array<Expr> = [];
    var argStrings: Array<String> = [];

    for(arg in args) {
      argStrings.push(printer.printExpr(arg));

      switch(arg.expr) {
        case ECall(_, _):
          var argString = '__${funName}_${argCounter} = ${printer.printExpr(arg)};';
          #if !macro
          vm.Process.self().processStack.getVariablesInScope().set('__${funName}_${argCounter}', 'Unknown');
          #end
          arg = macros.haxeToExpr(argString);
          var exprs: Array<Expr> = walkBlock(macroTools.buildBlock([arg]));
          for(expr in exprs) {
            retVal.push(expr);
          }

          types.push([Helpers.getType(StringTools.replace(macroContext.lastFunctionReturnType, '.', '_'), macroContext)]);
          funArgs.push(macroTools.getTuple([macroTools.getAtom("var"), '"__${funName}_${argCounter}"']));
        case _:
          var typeAndValue = macroTools.getTypeAndValue(arg);
          var typesForVar: Array<String> = getTypesForVar(typeAndValue, arg);
          
          var possibleTypes: Array<String> = [];
          for(typeForVar in typesForVar) {
            var type: String = Helpers.getType(typeForVar, macroContext);
            type = StringTools.replace(type, '.', '_');
            possibleTypes.remove(type);
            possibleTypes.push(type);
          }
          types.push(possibleTypes);
          funArgs.push(typeAndValue.value);
      }
    }

    var perms: Array<Array<String>> = [];
    generatePermutations(types, perms, 0, []);
    var possibleSignatures: Array<String> = [];

    for(typeArgs in perms) {
      var fqFunName: String = Helpers.makeFqFunName(funName, typeArgs);
      MacroLogger.log(fqFunName, 'fqFunName');
      var frags: Array<String> = fqFunName.split('.');
      fqFunName = frags.pop();
      var declaredFunctions: Map<String, Array<Dynamic>> = new Map<String, Array<Dynamic>>();
      if(module != null) {
        declaredFunctions = module.declaredFunctions;
      }

      var funDef: Dynamic = declaredFunctions.get(fqFunName);
      if(funDef == null) {
        var varTypeInScope: String = macroContext.varTypesInScope.getTypes(funName)[0];
        if(varTypeInScope == 'vm_Function' || varTypeInScope == 'vm.Function') {
          var haxeStr: String = 'ops.push(new vm.AnonymousFunction(${macroTools.getAtom(funName)}, ${macroTools.getList(funArgs)}, ${macroTools.getAtom(currentModuleStr)}, ${macroTools.getAtom(macroContext.currentFunction)}, ${lineNumber}, Code.annaLang))';
          retVal.push(macros.haxeToExpr(haxeStr));
          return retVal;
        }
      } else {
        #if macro
        macroContext.lastFunctionReturnType = funDef[0].funReturnTypes[0];
        #else
        var returnTypes: String = funDef[0].funReturnTypes;
        macroContext.lastFunctionReturnType = returnTypes.substr(1, returnTypes.length - 2);
        #end
        var expr = buildPushStackExpr(moduleName, fqFunName, funArgs, currentModuleStr, macroContext.currentFunction, lineNumber);
        retVal.push(expr);
        return retVal;
      }
    }
    throw new FunctionClauseNotFound('Function ${moduleName}.${funName} with args [${argStrings.join(', ')}] at line ${lineNumber} not found');
  }

  private inline function buildPushStackExpr(moduleName: String, fqFunName:
        String, funArgs:Array<String>, currentModuleStr: String,
        currentFunction, lineNumber: Int): Expr {
    var annaLangArg: Expr = macro Code.annaLang;

    return macro ops.push(new vm.PushStack($e{macroTools.getAtomExpr(moduleName)},
          $e{macroTools.getAtomExpr(fqFunName)},
          $e{macroTools.getListExpr(funArgs)},
          $e{macroTools.getAtomExpr(currentModuleStr)},
          $e{macroTools.getAtomExpr(currentFunction)},
          $e{macroTools.buildConst(CInt(lineNumber + ''))},
          $e{annaLangArg}));
  }

  private function getTypesForVar(typeAndValue: Dynamic, arg: Expr):Array<String> {
    return switch(arg.expr) {
      case EConst(CIdent(varName)):
        if(typeAndValue.rawValue == "vm_Function") {
          return ["vm_Function"];
        }
        if(macroContext.currentModuleDef.constants.get(varName) == null) {
          macroContext.varTypesInScope.getTypes(varName);
        } else {
          [typeAndValue.type];
        }
      case _:
        [typeAndValue.type];
    }
  }
  
  private function createPutIntoScope(expr: Expr, lineNumber: Int):Expr {
    var moduleName: String = macroTools.getModuleName(expr);
    moduleName = Helpers.getAlias(moduleName, macroContext);

    var args = macroTools.getFunBody(expr);
    var strArgs: Array<String> = [];
    for(arg in args) {
      var typeAndValue = macroTools.getTypeAndValue(arg);
      strArgs.push(typeAndValue.value);
    }
    macroContext.lastFunctionReturnType = getAnnaVarConstType(macros.haxeToExpr(strArgs.join(";")));
    return putIntoScope(strArgs.join(", "), lineNumber);
  }

  private function putIntoScope(args: String, lineNumber: Int): Expr {
    var currentModule: TypeDefinition = macroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    var currentFunction: String = macroContext.currentFunction;
    var currentFunStr: String = macroContext.currentVar;

    var haxeStr: String = '${currentFunStr}.push(new vm.PutInScope(${args}, Atom.create("${currentModuleStr}"), Atom.create("${currentFunction}"), ${lineNumber}, Code.annaLang));';
    return macros.haxeToExpr(haxeStr);
  }

  private function getAnnaVarConstType(expr):String {
    return switch(expr.expr) {
      case EMeta({name: 'tuple'}, {expr: EArrayDecl([_, e])}):
        var typeAndValue: Dynamic = macroTools.getTypeAndValue(e);
        typeAndValue.type;
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, "create")}, [{expr: EArrayDecl([_, e])}]):
        var typeAndValue: Dynamic = macroTools.getTypeAndValue(e);
        typeAndValue.type;
      case e:
        MacroLogger.log(e, 'e');
        throw "AnnaLang: Unexpected constant";
    }
  }

}
