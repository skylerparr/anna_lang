package lang;

using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class DefinedTypes {

  @field public static var typeSpecMap: Map<Atom, TypeSpec>;

  public static function start(): Void {
    if(typeSpecMap == null) {
      typeSpecMap = new Map<Atom, TypeSpec>();
    }
  }

  public static function stop(): Void {
    typeSpecMap = null;
  }

  public static function define(typeSpec: TypeSpec): Atom {
    typeSpecMap.set(typeSpec.name, typeSpec);
    return 'ok'.atom();
  }

  public static function getType(type: Atom): TypeSpec {
    return typeSpecMap.get(type);
  }

  public static function typesDefined(): Array<TypeSpec> {
    var retVal: Array<TypeSpec> = [];
    for(m in typeSpecMap) {
      retVal.push(m);
    }
    return retVal;
  }
}