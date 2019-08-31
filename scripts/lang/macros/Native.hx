package lang.macros;
import haxe.macro.Expr;
import hscript.plus.ParserPlus;
import haxe.macro.Printer;
import haxe.macro.Context;

class Native {

  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  public static var declaredFunctions: Map<String, TypeDefinition> = new Map<String, TypeDefinition>();

  public function new() {
  }

  #if macro
  public static function gen(params: Expr): Array<Expr> {
    var funName: String = MacroContext.currentVar;
    var moduleName: String = MacroTools.getModuleName(params);
    moduleName = AnnaLang.getAlias(moduleName);
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
          var exprs: Array<Expr> = AnnaLang.walkBlock(MacroTools.buildBlock([arg]));
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


  #end
}