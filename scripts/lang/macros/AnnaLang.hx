package lang.macros;

import hscript.plus.ParserPlus;
import haxe.macro.Printer;
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#if macro
using tink.MacroApi;
#end
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

  public static function _def(params: Expr): Expr {
    var funName: String = MacroTools.getCallFunName(params);
    MacroContext.currentFunction = funName;
    var body: Array<Expr> = [];
    var funBody: Array<Expr> = MacroTools.getFunBody(params);
    for(bodyExpr in funBody) {
      body = walkBlock(bodyExpr);
    }

    var funDef = MacroTools.buildPublicVar(funName, body);
    MacroTools.addFieldToClass(funDef);

    var returnType: ComplexType = MacroTools.buildType('Array<vm.Operation>');
    var field: Field = MacroTools.buildPublicFunction(funName, [], returnType);
    var expr: Expr = MacroTools.buildReturn(MacroTools.buildConst(CIdent('_${funName}')));
    MacroTools.assignFunBody(field, MacroTools.buildBlock([expr]));
    MacroTools.addFieldToClass(field);

    var returnType: ComplexType = MacroTools.buildType('Array<String>');
    var argFun = MacroTools.buildPublicFunction('___${funName}_args', [], returnType);
    var exprs: Array<Expr> = [];
    exprs.push(Macros.haxeToExpr('var args: Array<String> = [];'));
    var ret = MacroTools.buildReturn(MacroTools.buildConst(CIdent('args')));
    exprs.push(ret);
    MacroTools.assignFunBody(argFun, MacroTools.buildBlock(exprs));
    MacroTools.addFieldToClass(argFun);

    return macro {};
  }

  public static function _native(params: Expr):Expr {
    var funName: String = '_${MacroContext.currentFunction}';
    var nativeFun: String = MacroTools.getCallFunName(params);
    var args = MacroTools.getFunBody(params)[0];
    var argString = printer.printExpr(args);
    var haxeString = '${funName}.push(new vm.InvokeFunction(${nativeFun}, ${argString}))';
    return Macros.haxeToExpr(haxeString);
  }

  public static function _alias(params: Expr):Expr {

    return macro {};
  }
  
  #end

}