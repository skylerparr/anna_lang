package lang;

using lang.AtomSupport;

@:build(macros.ValueClassImpl.build())
class DefinedTypes {

  @field public static var moduleSpecMap: Map<Atom, TypeSpec>;

  public static function start(): Void {
    if(moduleSpecMap == null) {
      moduleSpecMap = new Map<Atom, TypeSpec>();
    }
  }

  public static function stop(): Void {
    moduleSpecMap = null;
  }

  public static function define(typeSpec: TypeSpec): Atom {
    moduleSpecMap.set(typeSpec.name, typeSpec);
    return 'ok'.atom();
  }

  public static function getType(type: Atom): TypeSpec {
    return moduleSpecMap.get(type);
  }

  public static function modulesDefined(): Array<TypeSpec> {
    var retVal: Array<TypeSpec> = [];
    for(m in moduleSpecMap) {
      retVal.push(m);
    }
    return retVal;
  }
}