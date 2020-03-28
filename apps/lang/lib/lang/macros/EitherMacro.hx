package lang.macros;

import lang.macros.MacroContext;
import lang.macros.AnnaLang;
import haxe.macro.Context;
import haxe.macro.Expr;
import lang.macros.MacroLogger;
import lang.macros.Macros;
import lang.ParsingException;
import haxe.macro.Printer;

class EitherMacro {
  private static var alphabet: Array<String> = {
    alphabet = [];
    var string = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for(i in 0...string.length) {
      alphabet.push(string.charAt(i));
    }
    alphabet;
  };

//  macro public static function gen(values: Expr): Expr {
//    MacroLogger.log("=====================");
//    MacroLogger.log('EitherMacro.gen(): ${Context.getLocalClass()}');
//    var macroContext = new MacroContext();
//    switch(setup(values)) {
//      case [p, valueExpressions, typeAndExprs, varTypeMap, allTypes, numberOfElements]:
//        var eitherArray: Array<Expr> = [];
//        var exprs: Array<Expr> = [];
//        for(i in 0...valueExpressions.length) {
//          var varType: String = alphabet[i];
//          var varName: String = varType.toLowerCase();
//          if(typeAndExprs.length == 0) {
//            return macro [];
//          }
//          var typeAndExpr: Dynamic = typeAndExprs[i];
//          var uniqueVarType: String = varTypeMap.get(typeAndExpr.type);
//          exprs.push({ expr: EVars([{ expr: { expr: typeAndExpr.expr, pos: MacroContext.currentPos() }, name: varName, type: TPath({ name: 'Tuple', pack: [], params: allTypes }) }]), pos: MacroContext.currentPos() });
//          eitherArray.push({expr: EConst(CIdent(varName)), pos: MacroContext.currentPos()});
//        }
//        exprs.push(macro $a{eitherArray});
//        return macro $b{exprs};
//      case _:
//        throw "EitherMacro.get(): gen setup return has changed, this shouldn't happen accidentally!";
//    }
//  }

  macro public static function genMap(values: Expr): Expr {
    var annaLang: AnnaLang = AnnaLang.annaLangForMacro;
    return doGenMap(annaLang, values);
  }

  public static function doGenMap(annaLang: AnnaLang, values: Expr): Expr {
    var macroContext: MacroContext = annaLang.macroContext;
    MacroLogger.log("=====================");

    switch(setup(annaLang, values)) {
      case [p, valueExpressions, typeAndExprs, varTypeMap, allTypes, numberOfElements]:
        var eitherArray: Array<Expr> = [];
        var exprs: Array<Expr> = [];
        var a: Expr = null;
        var b: Expr = null;
        if(typeAndExprs.length % 2 == 1) {
          for(t in cast(typeAndExprs, Array<Dynamic>)) {
            MacroLogger.logExpr(t.expr, 't.expr');
          }
          MacroLogger.log(typeAndExprs, 'typeAndExprs');
          MacroLogger.log(valueExpressions, 'valueExpressions');
          MacroLogger.logExpr(values, 'values');
          throw new ParsingException("AnnaLang: Unmatched map value. All maps must have a value to map to the key");
        }
        var argVars: Array<String> = [];
        for(i in 0...typeAndExprs.length) {
          var varType: String = alphabet[i];
          var varName: String = varType.toLowerCase();
          argVars.push(varName);
          var typeAndExpr: Dynamic = typeAndExprs[i];
          var uniqueVarType: String = varTypeMap.get(typeAndExpr.type);
          exprs.push({ expr: EVars([{ expr: typeAndExpr.expr, name: varName, type: TPath({ name: 'Tuple', pack: [], params: [] }) }]), pos: macroContext.currentPos() });

          if(a == null) {
            a = {expr: EConst(CIdent(varName)), pos: macroContext.currentPos()};
          } else if(b == null) {
            b = {expr: EConst(CIdent(varName)), pos: macroContext.currentPos()};
          }

          if(a != null && b != null) {
            eitherArray.push({ expr: ECall({ expr: EField({ expr: EConst(CIdent('map')), pos: macroContext.currentPos() },'set'), pos: macroContext.currentPos() },
            [a,b]), pos: macroContext.currentPos() });
            a = null;
            b = null;
          }
        }
        var eitherType = { name: 'Array', pack: [], params: allTypes };
        var newMap = annaLang.macros.haxeToExpr('[${argVars.join(', ')}]');
        exprs.push(newMap);
        return macro $b{exprs};
      case _:
        throw "EitherMacro.getMap(): gen setup return has changed, this shouldn't happen accidentally!";
    }
  }

  private static function setup(annaLang: AnnaLang, values: Expr):Array<Dynamic> {
    var macroContext: MacroContext = annaLang.macroContext;
    var p: Printer = annaLang.printer;
    var valueExpressions: Array<Dynamic> = switch(values) {
      case {expr: ECast({expr: EArrayDecl(expr)}, _)}:
        expr;
      case {expr: EObjectDecl(fields)}:
        fields;
      case e:
        MacroLogger.log(e, 'e');
        MacroLogger.logExpr(values, 'e');
        throw 'Either was unable to match type: Unsupported match';
    }

    var typeAndExprs: Array<Dynamic> = [];
    for(valueExpression in valueExpressions) {
      var vExpr: Expr = cast valueExpression;
      switch(vExpr.expr) {
        case EBinop(OpArrow, a, b):
          findTypesAndExprs(annaLang, typeAndExprs, a);
          findTypesAndExprs(annaLang, typeAndExprs, b);
        case _:
          findTypesAndExprs(annaLang, typeAndExprs, vExpr);
      }
    }

    var uniqueTypeMap: Map<String, String> = new Map<String, String>();
    for(type in typeAndExprs) {
      uniqueTypeMap.set(type.type, null);
    }
    var uniqueTypes: Array<String> = [];
    for(type in uniqueTypeMap.keys()) {
      uniqueTypes.push(type);
    }
    var varTypeMap: Map<String, String> = new Map<String, String>();
    var allTypes: Array<TypeParam> = [];
    var i: Int = 0;
    for(type in uniqueTypes) {
      allTypes.push(TPType(TPath({ name: type, pack: [], params: [] })));
      varTypeMap.set(type, alphabet[i++]);
    }
    var numberOfElements: Int = allTypes.length;
    return [
      p,
      valueExpressions,
      typeAndExprs,
      varTypeMap,
      allTypes,
      numberOfElements
    ];
  }

  private static function findTypesAndExprs(annaLang: AnnaLang, typeAndExprs: Array<Dynamic>, vExpr: Expr): Void {
    var macroContext: MacroContext = annaLang.macroContext;
    switch(vExpr) {
      case {expr: EConst(val)}:
        switch(val) {
          case CInt(value):
            typeAndExprs.push({type: "Int", expr: vExpr});
          case CString(value):
            typeAndExprs.push({type: "String", expr: vExpr});
          case CFloat(value):
            typeAndExprs.push({type: "Float", expr: vExpr});
          case CIdent(ident):
            var identExpr: Expr = {expr: EConst(CString(ident)), pos: macroContext.currentPos()}
            var expr: Expr = macro Tuple.create([Atom.create("var"), $e{identExpr}]);
            typeAndExprs.push({type: 'Dynamic', expr: expr});
          case _:
        }
      case {expr: ECall(val, _fun)}:
        switch(val) {
          case {expr: EField({expr: EConst(CString(_))}, _)}:
            typeAndExprs.push({type: "Atom", expr: vExpr});
          case {expr: EField({expr: EConst(CIdent(type))}, _)}:
            typeAndExprs.push({type: '${type}', expr: vExpr});
          case e:
            MacroLogger.log(e, 'e');
            MacroLogger.logExpr(e, 'e');
        }
      case {expr: ENew({name: type}, _args)}:
        typeAndExprs.push({type: {expr: EConst(CIdent(type)), pos: macroContext.currentPos()}, expr: vExpr});
      case {expr: EBinop(op, e1, e2)}:
        for(expr in [e1, e2]) {
          findTypesAndExprs(annaLang, typeAndExprs, expr);
        }
      case {expr: EMeta(_)}:
        var typesAndValues = annaLang.macroTools.getTypeAndValue(vExpr, macroContext);
        var expr = annaLang.macros.haxeToExpr(typesAndValues.value);
        findTypesAndExprs(annaLang, typeAndExprs, expr);
      case {expr: expr}:
        MacroLogger.log(vExpr, 'vExpr');
        MacroLogger.logExpr(vExpr, 'vExpr');
        findTypesAndExprs(annaLang, typeAndExprs, {expr: Reflect.field(expr, 'expr'), pos: macroContext.currentPos()});
      case e:
        MacroLogger.log(e, 'e');
    }
  }
}