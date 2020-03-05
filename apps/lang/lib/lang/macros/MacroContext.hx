package lang.macros;
import haxe.rtti.Rtti;
import haxe.macro.Expr;
import haxe.macro.Type;

class MacroContext {

  public function clone(): MacroContext {
    var mc: MacroContext = new MacroContext(annaLang);
    mc.currentModule = this.currentModule;
    mc.currentFunction = this.currentFunction;
    mc.currentVar = this.currentVar;
    for(aliasKey in this.aliases.keys()) {
      mc.aliases.set(aliasKey, this.aliases.get(aliasKey));
    }
    mc.currentFunctionArgTypes = [];
    var thisCurrentFAT = this.currentFunctionArgTypes;
    if(thisCurrentFAT == null) {
      thisCurrentFAT = [];
    }
    for(cf in thisCurrentFAT) {
      mc.currentFunctionArgTypes.push(cf);
    }
    mc.varTypesInScope = this.varTypesInScope.clone();
    mc.lastFunctionReturnType = this.lastFunctionReturnType;
    for(key in associatedInterfaces.keys()) {
      mc.associatedInterfaces.set(key, associatedInterfaces.get(key));
    }
    for(key in declaredClasses.keys()) {
      mc.declaredClasses.set(key, declaredClasses.get(key));
    }
    for(key in declaredInterfaces.keys()) {
      mc.declaredInterfaces.set(key, declaredInterfaces.get(key));
    }
    for(type in declaredTypes) {
      mc.declaredTypes.push(type);
    }
    for(key in typeFieldMap.keys()) {
      mc.typeFieldMap.set(key, typeFieldMap.get(key));
    }
    mc.currentModuleDef = this.currentModuleDef;
    return mc;
  }

  @:isVar
  public var currentModule(get, set): TypeDefinition;
  @:isVar
  public var currentFunction(get, set): String;
  public var currentVar: String;
  public var aliases: Map<String, String> = new Map<String, String>();
  public var currentFunctionArgTypes: Array<String>;
  public var typeFieldMap: Map<String, Map<String, String>> = new Map<String, Map<String, String>>();
  public var declaredTypes: Array<String> = [];

  @:isVar
  public var varTypesInScope(get, set): VarTypesInScope;

  @:isVar
  public var lastFunctionReturnType(get, set): String;
  public var associatedInterfaces: Map<String, String> = new Map<String, String>();
  public var declaredClasses: Map<String, ModuleDef> = new Map<String, ModuleDef>();
  public var declaredInterfaces: Map<String, ModuleDef> = new Map<String, ModuleDef>();

  @:isVar
  public var currentModuleDef(get, set):ModuleDef;

  private function get_currentModule(): TypeDefinition {
    if(currentModule == null) {
      currentModule = defaultTypeDefinition;
    }
    return currentModule;
  }

  private function set_currentModule(mod: TypeDefinition): TypeDefinition {
    currentModule = mod;
    return currentModule;
  }

  function get_currentFunction(): String {
    if(currentFunction == null) {
      currentFunction = "__default__";
    }
    return currentFunction;
  }

  function set_currentFunction(value: String): String {
    return currentFunction = value;
  }

  function get_currentModuleDef():ModuleDef {
    if(currentModuleDef == null) {
      currentModuleDef = defaultModuleDef;
    }
    return currentModuleDef;
  }

  function set_currentModuleDef(value:ModuleDef):ModuleDef {
    return currentModuleDef = value;
  }

  function get_varTypesInScope(): VarTypesInScope {
    if(varTypesInScope == null) {
      varTypesInScope = new VarTypesInScope();
    }
    return varTypesInScope;
  }

  function set_varTypesInScope(value: VarTypesInScope): VarTypesInScope {
    return varTypesInScope = value;
  }

  function get_lastFunctionReturnType(): String {
    return lastFunctionReturnType;
  }

  function set_lastFunctionReturnType(value: String): String {
    return lastFunctionReturnType = value;
  }

  public var defaultTypeDefinition: TypeDefinition =
  {
    var dtd = {
      pack: ["dkjf", "skljf", "kopaioe", "odfkpewp"],
      name: "__DefaultType__",
      #if macro
      pos: haxe.macro.Context.currentPos(),
      #else
      pos: {file: "none:0", min: 0, max: 0},
      #end
      kind: TDStructure,
      fields: []
    }
    dtd;
  }

  public var defaultModuleDef: ModuleDef = new ModuleDef("__DEFAULT_MODULE__");

  private var annaLang: AnnaLang;

  public function new(annaLang: AnnaLang) {
    this.annaLang = annaLang;
  }

  #if macro
  public function currentPos():Dynamic {
    return haxe.macro.Context.currentPos();
  }
  #else
  public function currentPos():Position {
    return {file: "none:0", min: 0, max: 0};
  }
  #end

  #if macro
  public function typeof(expr: Expr):haxe.macro.Type {
    return haxe.macro.Context.typeof(expr);
  }
  #else
  public function typeof(expr: Expr):haxe.macro.Type {
    return TLazy(function() {
      return TDynamic(null);
    });
  }
  #end

  #if macro
  public function defineType(cls: TypeDefinition):Void {
    return haxe.macro.Context.defineType(cls);
  }
  #else
  public var definedClass: TypeDefinition;

  public function defineType(cls: TypeDefinition):Void {
    this.definedClass = cls;
  }
  #end

  #if macro
  public function makeExpr(v:Dynamic, pos:Position):Expr {
    return haxe.macro.Context.makeExpr(v, pos);
  }
  #else
  public function makeExpr(v:Dynamic, pos:Position):Expr {
    return macro{};
  }
  #end

  public function getFieldType(name: String, fieldName: String): String {
    var map: Map<String, String> = typeFieldMap.get(name);
    return map.get(fieldName);
  }

  public function getLine(): Expr {
    var lineStr = currentPos() + '';
    var lineNo: Int = Std.parseInt(lineStr.split(':')[1]);
    return annaLang.macros.haxeToExpr('${lineNo}');
  }

  #if !macro

  public function saveType(typeName: String, obj: Dynamic, typeFieldMap: Map<String, String>): Void {
//    this.declaredTypes.push(typeName);
//    vm.Lang.definedModules(typeName, obj);
//    this.typeFieldMap.set(typeName, typeFieldMap);
  }

  #end
}

