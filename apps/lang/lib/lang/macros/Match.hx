package lang.macros;

import lang.macros.MacroTools;
import lang.macros.MacroTools;
import hscript.plus.ParserPlus;
import haxe.macro.Printer;
import haxe.macro.Expr;
class Match {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  // Ensures that all pattern matches are unique
  private static var _id: Int = 0;
  private static var matchMap: Map<String, String> = new Map<String, String>();

  public static function gen(params: Expr): Array<Expr> {
    var typeAndValue = MacroTools.getTypeAndValue(params);
    if(typeAndValue.type == "Variable") {
      var moduleName: String = MacroTools.getModuleName(params);
      moduleName = AnnaLang.getAlias(moduleName);

      var currentModule: TypeDefinition = MacroContext.currentModule;
      var currentModuleStr: String = currentModule.name;
      var currentFunStr: String = MacroContext.currentVar;
      var varName: String = MacroTools.getIdent(params);
      MacroContext.varTypesInScope.set(varName, MacroContext.lastFunctionReturnType);
      var haxeStr: String = '${currentFunStr}.push(new vm.Assign(${MacroTools.getTuple([MacroTools.getAtom("const"), '"${varName}"'])}, ${MacroTools.getAtom(currentModuleStr)}, ${MacroTools.getAtom(MacroContext.currentFunction)}, ${MacroTools.getLineNumber(params)}));';
      return [lang.macros.Macros.haxeToExpr(haxeStr)];
    } else {
      var currentModule: TypeDefinition = MacroContext.currentModule;
      var currentModuleStr: String = currentModule.name;

      MacroLogger.log(typeAndValue, 'match typeAndValue');
      var patternMatch: Expr = PatternMatch.match(Macros.haxeToExpr(typeAndValue.value), Macros.haxeToExpr("scopeVariables.get(\"$$$\")"));
      #if macro
      var cls: TypeDefinition = macro class NoClass extends vm.AbstractMatch {
          public function new(hostModule: Atom, hostFunction: Atom, line: Int) {
            super(hostModule, hostFunction, line);
          }

          override public function execute(scopeVariables: Map<String, Dynamic>, processStack: vm.ProcessStack): Void {
            var matched: Map<String, Dynamic> = $e{patternMatch};
            if(Kernel.isNull(matched)) {
              Logger.inspect('BadMatch: ${currentModuleStr}.${MacroContext.currentFunction}():${MacroTools.getLineNumber(params)} => ${printer.printExpr(params)}');
              IO.inspect('BadMatch: ${currentModuleStr}.${MacroContext.currentFunction}():${MacroTools.getLineNumber(params)} => ${printer.printExpr(params)}');
              vm.Kernel.crash(vm.Process.self());
              return;
            }
            for(key in matched.keys()) {
              scopeVariables.set(key, matched.get(key));
            }
          }
      }
      AnnaLang.applyBuildMacro(cls);

      var className: String = '___${_id++}';
      cls.name = className;
      cls.pack = ["vm"];
      MacroLogger.printFields(cls.fields);

      MacroContext.defineType(cls);

      return [Macros.haxeToExpr('ops.push(new vm.${className}(${MacroTools.getAtom(currentModuleStr)}, ${MacroTools.getAtom(MacroContext.currentFunction)}, ${MacroTools.getLineNumber(params)}));')];
      #else
      return [Macros.haxeToExpr('ops.push(new vm.InterpMatch(${params}, ${MacroTools.getAtom(currentModuleStr)}, ${MacroTools.getAtom(MacroContext.currentFunction)}, ${MacroTools.getLineNumber(params)}));')];
      #end
    }
  }
}