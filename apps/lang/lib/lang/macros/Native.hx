package lang.macros;
import lang.macros.AnnaLang;
import lang.macros.MacroTools;
import haxe.macro.Expr;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Expr;
import haxe.macro.Context;
class Native {

  public static var declaredFunctions: Map<String, TypeDefinition> = new Map<String, TypeDefinition>();

  public static function gen(annaLang: AnnaLang, params: Expr): Array<Expr> {
    var macroContext: MacroContext = annaLang.macroContext;
    var macroTools: MacroTools = annaLang.macroTools;
    var macros: Macros = annaLang.macros;
    var printer = annaLang.printer;

    var funName: String = macroContext.currentVar;
    var moduleName: String = macroTools.getModuleName(params);
    moduleName = Helpers.getAlias(moduleName, macroContext);
    var invokeFunName = macroTools.getFunctionName(params);
    var args = macroTools.getFunBody(params);
    var retVal: Array<Expr> = [];
    var strArgs: Array<String> = [];
    var argCounter: Int = 0;
    for(arg in args) {
      switch(arg.expr) {
        case ECall(_, _):
          var argString = '__${invokeFunName}_${argCounter} = ${printer.printExpr(arg)};';
          arg = annaLang.macros.haxeToExpr(argString);
          var exprs: Array<Expr> = annaLang.walkBlock(macroTools.buildBlock([arg]));
          for(expr in exprs) {
            retVal.push(expr);
          }

          strArgs.push(macroTools.getTuple([macroTools.getAtom('var'), '"__${invokeFunName}_${argCounter}"']));
        case _:
          var typeAndValue = macroTools.getTypeAndValue(arg, macroContext);
          strArgs.push(typeAndValue.value);
      }
      argCounter++;
    }
    var currentModule: TypeDefinition = macroContext.currentModule;
    var currentModuleStr: String = currentModule.name;

    var invokeClass: TypeDefinition = createOperationClass(annaLang, moduleName, invokeFunName, strArgs);

    var haxeString = '${funName}.push(new vm.${invokeClass.name}(${moduleName}.${invokeFunName}, ${macroTools.getList(strArgs)}, "${moduleName}", "${invokeFunName}",
      ${macroTools.getAtom(currentModuleStr)}, ${macroTools.getAtom(macroContext.currentFunction)}, ${macroTools.getLineNumber(params)}, Code.annaLang))';
    MacroLogger.log(haxeString, 'haxeString');
    retVal.push(macros.haxeToExpr(haxeString));
    return retVal;
  }

  private static function createOperationClass(annaLang: AnnaLang, moduleName: String, invokeFunName: String, strArgs: Array<String>): TypeDefinition {
    var macroContext: MacroContext = annaLang.macroContext;
    var macroTools: MacroTools = annaLang.macroTools;
    var macros: Macros = annaLang.macros;

    #if macro
    var className = 'InvokeFunction_${StringTools.replace(moduleName, '.', '_')}_${StringTools.replace(invokeFunName, '.', '_')}';
    #else
    var className = 'InvokeNativeFunctionOperation';
    #end

    var assignments: Array<String> = [];
    var paramVars: Array<Field> = [];
    var counter: Int = 0;
    var privateArgs: Array<String> = [];
    for(arg in strArgs) {
      var assign: String = 'var _arg${counter} = ArgHelper.extractArgValue(arg${counter}, scope, annaLang);';
      var classVar: String = 'arg${counter}';
      var paramVar = macro class Fake {
        private var $classVar: Tuple;
      }
      paramVars.push(paramVar.fields[0]);
      assignments.push(assign);
      privateArgs.push('_arg${counter}');
      ++counter;
    }
    var executeBodyStr: String = '${assignments.join('\n')} ${moduleName}.${invokeFunName}(${privateArgs.join(', ')});';

    // save the return type in compiler scope to check types later
    var args: Array<String> = privateArgs.map(function(arg) { return 'null'; });
    var expr: Expr = macros.haxeToExpr('${moduleName}.${invokeFunName}(${args.join(', ')})');
    macroContext.lastFunctionReturnType = macroTools.resolveType(expr);

    if(declaredFunctions.get(className) == null) {
      var assignReturnVar: Expr = macro {};
      if(macroContext.lastFunctionReturnType == "Int" || macroContext.lastFunctionReturnType == "Float") {
        executeBodyStr = 'var retVal = {${executeBodyStr}}';
        assignReturnVar = macro scope.set("$$$", retVal);
        macroContext.lastFunctionReturnType = "Number";
      } else {
        if(macroContext.lastFunctionReturnType != "Void") {
          assignReturnVar = macro if(retVal == null) {
                scope.set("$$$", lang.HashTableAtoms.get("nil"));
              } else {
                scope.set("$$$", retVal);
              }
          executeBodyStr = 'var retVal = {${executeBodyStr}}';
        }
      }

      var execBody: Expr = macros.haxeToExpr(executeBodyStr);
      #if macro
      var cls: TypeDefinition = macro class NoClass extends vm.AbstractInvokeFunction {

          public function new(func: Dynamic, args: LList, classString: String, funString: String, hostModule: Atom, hostFunction: Atom, line: Int, annaLang: lang.macros.AnnaLang) {
            super(hostModule, hostFunction, line, annaLang);
            var counter: Int = 0;
            for(arg in LList.iterator(args)) {
              var tuple: Tuple = lang.EitherSupport.getValue(arg);
              Reflect.setField(this, "arg" + (counter++), tuple);
            }
          }

          override public function execute(scope: Map<String, Dynamic>, processStack: vm.ProcessStack): Void {
            $e{execBody}
            $e{assignReturnVar}
          }
      }
      #else
      var cls: TypeDefinition = macro class InvokeNativeFunctionOperation {

      }
      #end

      for(paramVar in paramVars) {
        macroTools.addFieldToClass(cls, paramVar);
      }

      cls.name = className;
      cls.pack = ["vm"];

      macroContext.defineType(cls);

      declaredFunctions.set(className, cls);
      return cls;
     } else {
      return declaredFunctions.get(className);
    }
  }
}