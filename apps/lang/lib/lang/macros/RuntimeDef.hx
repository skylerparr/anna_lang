package lang.macros;

import hscript.Interp;
import haxe.macro.Expr;

class RuntimeDef {
  public var annaLang: AnnaLang;
  private var moduleDefines: Array<Dynamic>;
  private var setIfaces: Array<Dynamic>;

  public function new(annaLang: AnnaLang) {
    this.annaLang = annaLang;
    moduleDefines = [];
    setIfaces = [];
  }

  private inline function getCodeModule(): Dynamic {
    return Type.resolveClass("Code");
  }

  public function declareInterface(interfaceName: String, moduleDef: ModuleDef): Void {
    var code = getCodeModule();
    code.annaLang.macroContext.declaredInterfaces.set(interfaceName, moduleDef);  
  }

  public function defType(typeName: String, fieldMap: Map<String, String>): Void {
    var code = getCodeModule();
    var macroContext: MacroContext = code.annaLang.macroContext;
    macroContext.typeFieldMap.set(typeName, fieldMap);
    macroContext.declaredTypes.push(typeName);
  }

  public function setIFace(iface: String, impl: String): Void {
    setIfaces.push({iface: iface, impl: impl});
  }

  public function declareModule(moduleName: String, moduleDef: ModuleDef): Void {
    var code: Dynamic = getCodeModule();
    code.annaLang.macroContext.declaredClasses.set(moduleName, moduleDef);
  }

  public function getIFace(iface: String): ModuleDef {
    var code: Dynamic = getCodeModule();
    var macroContext: MacroContext = code.annaLang.macroContext;
    return macroContext.declaredInterfaces.get(iface);
  }

  public function defineRuntimeModule(macroContext: MacroContext, macroTools: MacroTools): Void {
    var code: Dynamic = getCodeModule();
    var moduleDef = macroContext.currentModuleDef;
    var moduleName = moduleDef.moduleName;
    var instance: Dynamic = {};

    code.annaLang.macroContext.declaredClasses.set(moduleName, moduleDef);
    moduleDefines.push({
      moduleName: moduleName, 
      instance: instance, 
      moduleDef: macroContext.currentModuleDef,
      fields: []
    });
  }

  private function doDefineModule(moduleName: String, moduleDef: ModuleDef, instance: Dynamic, fields: Array<Dynamic>): Void {
    var parser = annaLang.parser;
    var printer = annaLang.printer;
    var macroTools = annaLang.macroTools;

    var functions: Map<String, Dynamic> = new Map();
    for(field in fields) {
      switch(field.kind) {
        case FVar(t, expr):
          var ast = parser.parseString(printer.printExpr(expr));
          var operations: Array<vm.Operation> = vm.Lang.getHaxeInterp().execute(ast);
          Reflect.setField(instance, field.name, operations);
        case FFun(f):
          functions.set(field.name, f);
        case _:
          throw new ParsingException("AnnaLang defineRuntimeModule: Unexpected field type FProp");
      }
    }
    var instanceFields: Array<String> = Reflect.fields(instance);
    for(funcKey in functions.keys()) {
      var interp: Interp = vm.Lang.getHaxeInterp();
      for(field in instanceFields) {
        interp.variables.set(field, Reflect.field(instance, field));
      }
      var func = functions.get(funcKey);
      var args: Array<String> = {
        var retVal: Array<String> = [];
        for(funArg in cast(func.args, Array<Dynamic>)) {
          retVal.push('${funArg.name}: ${macroTools.getType(funArg.type)}');
        }
        retVal;
      }
      var bodyString: String = printer.printExpr(func.expr);
      var anonFuncString: String = 'function(${args.join(', ')}) {
                  ${bodyString}
                }';
      var ast = parser.parseString(anonFuncString);
      var anonFunc = interp.execute(ast);
      Reflect.setField(instance, funcKey, anonFunc);
    }
  }

  public function commit(): Void {
    //swap in the vm.Classes with mutex to ensure thread safety
    for(module in moduleDefines) {
      annaLang.compileModule(module.moduleName, module.moduleDef);
      var fields: Array<Dynamic> = annaLang.macroContext.definedClass.fields;
      doDefineModule(module.moduleName, module.moduleDef, module.instance, fields);
    }
    var code: Dynamic = getCodeModule();
    for(iface in setIfaces) {
      var ifaceName: String = iface.iface;
      var moduleName: String = iface.impl;
      var macroContext: MacroContext = code.annaLang.macroContext;

      var moduleDef: ModuleDef = macroContext.declaredClasses.get(moduleName);
      if(moduleDef == null) {
        throw new ModuleNotFoundException('AnnaLang: module ${moduleName} not found');
      }

      macroContext.associatedInterfaces.set(ifaceName, moduleName);
      macroContext.declaredInterfaces.set(ifaceName, moduleDef); 
    }
    for(moduleDefine in moduleDefines) {
      var fields = Reflect.fields(moduleDefine.instance);
      vm.Classes.defineWithInstance(
        Atom.create(moduleDefine.moduleName),
        moduleDefine.instance,
        fields
      );
    }
    for(iface in setIfaces) {
      var ifaceName: String = iface.iface;
      var moduleName: String = iface.impl;

      vm.Classes.setIFace(Atom.create(ifaceName), Atom.create(moduleName));
    }
    //swap out thread safe vm.Classes
  }
}
