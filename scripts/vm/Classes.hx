package vm;

@:build(lang.macros.ValueClassImpl.build())
class Classes {

  @field public var classes: Map<Atom, Class<Dynamic>>;

  public static inline function define(name: Atom, classDef: Class<Dynamic>): Void {
    if(classes == null) {
      classes = new Map<Atom, Class<Dynamic>>();
    }
    classes.set(name, classDef);
  }

  public static inline function getClass(name: Atom): Class<Dynamic> {
    return classes.get(name);
  }
}