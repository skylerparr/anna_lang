package vm;

using lang.AtomSupport;

@:build(lang.macros.ValueClassImpl.build())
class Classes {

  @field public static var classes: Map<Atom, Class<Dynamic>>;
  @field public static var functions: Map<Atom, Map<Atom, Dynamic>>;

  public static inline function define(name: Atom, classDef: Class<Dynamic>): Void {
    if(classes == null) {
      classes = new Map<Atom, Class<Dynamic>>();
    }
    classes.set(name, classDef);

    if(functions == null) {
      functions = new Map<Atom, Map<Atom, Dynamic>>();
    }
    var funMap: Map<Atom, Dynamic> = functions.get(name);
    if(funMap == null) {
      funMap = new Map<Atom, Dynamic>();
    }
    var funcs: Array<Dynamic> = Type.getClassFields(classDef);
    for(fun in funcs) {
      var funAtom: Atom = '${fun}'.atom();
      funMap.set(funAtom, Reflect.field(classDef, fun));
    }
    functions.set(name, funMap);
  }

  public static inline function getClass(name: Atom): Class<Dynamic> {
    return classes.get(name);
  }

  public static inline function getFunction(className: Atom, funName: Atom): Dynamic {
    var funMap: Map<Atom, Dynamic> = functions.get(className);
    if(funMap != null) {
      return funMap.get(funName);
    }
    return null;
  }
}