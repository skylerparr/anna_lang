package tests;

typedef Pizza = {
  toppings: String,
  cost: Int
}

@:build(macros.ScriptMacros.script())
class P {

  public static function mod(a: Int, b: Int): Int {
    var scopeVariables: Map<String, Dynamic> = new Map<String, Dynamic>();
    var get: String->Dynamic = scopeVariables.get;
    var set: String->Dynamic->Void = scopeVariables.set;
    switch([a, b]) {
      case _:
        set("a", a);
        set("b", b);
    }
    var v1 = rem(get("a"), get("b"));

    var v2 = cook(get("a"), add(get("b"), 212));
    var _pizza1 = {toppings: v2.toppings, cost: v2.cost};
    switch(_pizza1) {
      case {cost: cost}:
        set("pza", cost);
    }
    return get("pza");
  }

  public static function cook(a: Int, b: Int): Pizza {
    return {toppings: "Pinneapple", cost: add(a, b)}
  }

  public static function add(a: Int, b: Int): Int {
    return a + b;
  }

  public static function rem(a: Int, b: Int): Int {
    return a % b;
  }

  public static function bindVar(varName: String, value: Dynamic, scope: Map<String, Dynamic>): Void {
    
    scope.set(varName, value);
  }
}