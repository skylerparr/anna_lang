package lang.macros;
import haxe.rtti.Rtti;
import haxe.macro.Expr;

class MacroContext {
  @:isVar
  public var currentModule(get, set): TypeDefinition;
  @:isVar
  public var currentFunction(get, set): String;
  public var currentVar: String;
  public var aliases: Map<String, String> = new Map<String, String>();
  public var currentFunctionArgTypes: Array<String>;

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
  public function defineType(cls: TypeDefinition):Void {

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

  public function getLine(): Expr {
    var lineStr = currentPos() + '';
    var lineNo: Int = Std.parseInt(lineStr.split(':')[1]);
    return annaLang.macros.haxeToExpr('${lineNo}');
  }
}

