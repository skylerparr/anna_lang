package lang.macros;

import hscript.plus.ParserPlus;
import haxe.macro.Printer;
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
class AnnaLang {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  macro public static function defcls(name: Expr, body: Expr): Array<Field> {
    MacroLogger.log('==============================');
    var className: String = printer.printExpr(name);
    MacroLogger.log(className, 'name');
    MacroLogger.logExpr(body, 'bodyString');
    MacroLogger.log(body, 'body');

    var cls = MacroTools.createClass(className);
    MacroContext.currentModule = cls;
    MacroContext.aliases = new Map<String, String>();
    applyBuildMacro();

    walkBlock(body);

    Context.defineType(cls);

    MacroLogger.log("==================");
    MacroLogger.log('Fields for ${className}');
    MacroLogger.log('------------------');
    MacroLogger.printFields(cls.fields);
    MacroLogger.log("------------------");
    return [];
  }

  #if macro
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
              var expr: Expr = createPushStack(funName, args);
              retExprs.push(expr);
            case _:
              blockExpr;
          }
        }
      case _:
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

  private static function createPushStack(funName: String, args: Array<Expr>):Expr {
    var currentModule: TypeDefinition = MacroContext.currentModule;
    var currentModuleStr: String = currentModule.name;
    var currentFunStr: String = '_${MacroContext.currentFunction}';
    var haxeStr: String = '${currentFunStr}.push(new vm.PushStack(@atom "${currentModuleStr}", @atom "${funName}", @list [], "${currentModuleStr}", "${currentFunStr}}", 1))';
    return Macros.haxeToExpr(haxeStr);
  }

  public static function _def(params: Expr): Expr {
    var funName: String = MacroTools.getCallFunName(params);
    MacroContext.currentFunction = funName;
    var varName: String = '_${funName}';
    var body: Array<Expr> = [];
    var funBody: Array<Expr> = MacroTools.getFunBody(params);
    body.push({
      expr: EBinop(OpAssign,{
        expr: EConst(CIdent(varName)),
        pos: Context.currentPos()
      },{
        expr: EArrayDecl([]),
        pos: Context.currentPos()
      }),
      pos: Context.currentPos()
    });

    for(bodyExpr in funBody) {
      var walkBody = walkBlock(bodyExpr);
      for(expr in walkBody) {
        body.push(expr);
      }
    }
    body.push(MacroTools.buildConst(CIdent(varName)));

    var varType: ComplexType = MacroTools.buildType('Array<vm.Operation>');
    var funDef = MacroTools.buildPublicVar(funName, varType, body);
    MacroTools.addFieldToClass(funDef);

    var returnType: ComplexType = MacroTools.buildType('Array<vm.Operation>');
    var field: Field = MacroTools.buildPublicFunction(funName, [], returnType);
    var expr: Expr = MacroTools.buildReturn(MacroTools.buildConst(CIdent('_${funName}')));
    MacroTools.assignFunBody(field, MacroTools.buildBlock([expr]));
    MacroTools.addFieldToClass(field);

    var varType: ComplexType = MacroTools.buildType('Array<String>');
    var exprs: Array<Expr> = [];
    exprs.push(Macros.haxeToExpr('var args: Array<String> = [];'));
    var ret = MacroTools.buildConst(CIdent('args'));
    exprs.push(ret);
    var argFun = MacroTools.buildPublicVar('___${funName}_args', varType, exprs);
    MacroTools.addFieldToClass(argFun);

    return macro {};
  }

  public static function _native(params: Expr):Expr {
    var funName: String = '_${MacroContext.currentFunction}';
    var moduleName: String = MacroTools.getModuleName(params);
    moduleName = getAlias(moduleName);
    var invokeFunName = MacroTools.getFunctionName(params);
    var args = MacroTools.getFunBody(params);
    var strArgs: Array<String> = [];
    for(arg in args) {
      strArgs.push(printer.printExpr(arg));
    }
    var haxeString = '${funName}.push(new vm.InvokeFunction(${moduleName}.${invokeFunName}, @list[${strArgs.join(', ')}], "${moduleName}", "${funName}", ${MacroTools.getLineNumber()}))';
    return Macros.haxeToExpr(haxeString);
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

  #end

}