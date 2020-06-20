package lang.macros;

import lang.macros.AnnaLang;
import lang.macros.MacroTools;
import haxe.macro.Printer;
import haxe.macro.Expr;
class Match {
  private static var _id: Int = 0;

  public static function gen(annaLang: AnnaLang, params: Expr): Array<Expr> {
    var macroTools: MacroTools = annaLang.macroTools;
    var macroContext: MacroContext = annaLang.macroContext;
    var macros: Macros = annaLang.macros;
    var printer: Printer = annaLang.printer;

    var typeAndValue = macroTools.getTypeAndValue(params, macroContext);
    if(typeAndValue.type == "Variable") {
      var moduleName: String = macroTools.getModuleName(params);
      moduleName = Helpers.getAlias(moduleName, macroContext);

      var currentModule: TypeDefinition = macroContext.currentModule;
      var currentModuleStr: String = currentModule.name;
      var currentFunStr: String = macroContext.currentVar;
      var varName: String = macroTools.getIdent(params);
      macroContext.varTypesInScope.set(varName, macroContext.lastFunctionReturnType);
      var haxeStr: String = '${currentFunStr}.push(new vm.Assign(${macroTools.getTuple([macroTools.getAtom("const"), '"${varName}"'])}, ${macroTools.getAtom(currentModuleStr)}, ${macroTools.getAtom(macroContext.currentFunction)}, ${macroTools.getLineNumber(params)}, Code.annaLang));';
      return [macros.haxeToExpr(haxeStr)];
    } else {
      var currentModule: TypeDefinition = macroContext.currentModule;
      var currentModuleStr: String = currentModule.name;

      var patternMatch: Expr = PatternMatch.match(annaLang, macros.haxeToExpr(typeAndValue.value), macros.haxeToExpr("____scopeVariables.get(\"$$$\")"));
      var scopeExpr: Expr = macros.haxeToExpr('var scope:haxe.ds.StringMap<Dynamic> = new haxe.ds.StringMap();');
      patternMatch = macroTools.buildBlock([scopeExpr, patternMatch]);
      #if macro
      var cls: TypeDefinition = macro class NoClass extends vm.AbstractMatch {
          public function new(hostModule: Atom, hostFunction: Atom, line: Int, annaLang: lang.macros.AnnaLang) {
            super(hostModule, hostFunction, line, annaLang);
          }

          override public function execute(____scopeVariables: Map<String, Dynamic>, processStack: vm.ProcessStack): Void {
            var matched: Map<String, Dynamic> = $e{patternMatch};
         
            if(NativeKernel.isNull(matched)) {
              IO.inspect('BadMatch: ${currentModuleStr}.${macroContext.currentFunction}():${macroTools.getLineNumber(params)} => ${printer.printExpr(params)} != ' + Anna.toAnnaString(____scopeVariables.get("$$$")));
              vm.NativeKernel.crash(vm.Process.self());
              return;
            }
            for(key in matched.keys()) {
              ____scopeVariables.set(key, matched.get(key));
            }
          }
      }
      Helpers.applyBuildMacro(annaLang, cls);

      var className: String = '___${_id++}';
      cls.name = className;
      cls.pack = ["vm"];

      var moduleDef: ModuleDef = new ModuleDef(cls.name);
      moduleDef.extend = "vm.AbstractMatch";
      macroContext.compiledModules.set(moduleDef.moduleName, moduleDef);
      var codeString: String = "";
      for(field in cls.fields) {
        codeString += printer.printField(field) + ";";
      }
      moduleDef.codeString = codeString;
      moduleDef.pack = "vm";


      macroContext.defineType(cls);

      return [macros.haxeToExpr('ops.push(new vm.${className}(${macroTools.getAtom(currentModuleStr)}, ${macroTools.getAtom(macroContext.currentFunction)}, ${macroTools.getLineNumber(params)}, Code.annaLang));')];
      #else
      return [macros.haxeToExpr('ops.push(new InterpMatch(\'${printer.printExpr(patternMatch)}\', ${macroTools.getAtom(currentModuleStr)}, ${macroTools.getAtom(macroContext.currentFunction)}, ${macroTools.getLineNumber(params)}, Code.annaLang));')];
      #end
    }
  }
}
