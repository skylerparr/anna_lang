package lang.macros;

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

  macro public static function gen(values: Expr): Expr {
    MacroLogger.log("=====================");
    MacroLogger.log('EitherMacro.gen(): ${Context.getLocalClass()}');
    switch(setup(values)) {
      case [p, valueExpressions, typeAndExprs, varTypeMap, allTypes, numberOfElements]:
        var eitherArray: Array<Expr> = [];
        var exprs: Array<Expr> = [];
        for(i in 0...valueExpressions.length) {
          var varType: String = alphabet[i];
          var varName: String = varType.toLowerCase();
          if(typeAndExprs.length == 0) {
            return macro [];
          }
          var typeAndExpr: Dynamic = typeAndExprs[i];
          var uniqueVarType: String = varTypeMap.get(typeAndExpr.type);
          exprs.push({ expr: EVars([{ expr: { expr: ECall({ expr: EConst(CIdent(uniqueVarType)), pos: MacroContext.currentPos() },[typeAndExpr.expr]), pos: MacroContext.currentPos() }, name: varName, type: TPath({ name: 'EitherEnums', sub: 'Either${numberOfElements}', pack: [], params: allTypes }) }]), pos: MacroContext.currentPos() });
          eitherArray.push({expr: EConst(CIdent(varName)), pos: MacroContext.currentPos()});
        }
        exprs.push(macro $a{eitherArray});
        return macro $b{exprs};
      case _:
        throw "EitherMacro.get(): gen setup return has changed, this shouldn't happen accidentally!";
    }
  }

  macro public static function genMap(values: Expr): Expr {
    return doGenMap(values);
  }

  public static function doGenMap(values: Expr): Expr {
    MacroLogger.log("=====================");
//    MacroLogger.log('EitherMacro.genMap(): ${MacroContext.getLocalClass()}');

    switch(setup(values)) {
      case [p, valueExpressions, typeAndExprs, varTypeMap, allTypes, numberOfElements]:
        var eitherArray: Array<Expr> = [];
        var exprs: Array<Expr> = [];
        var a: Expr = null;
        var b: Expr = null;
        if(typeAndExprs.length % 2 == 1) {
          MacroLogger.log(typeAndExprs, 'typeAndExprs');
          MacroLogger.log(valueExpressions, 'valueExpressions');
          MacroLogger.logExpr(values, 'values');
          throw new ParsingException("AnnaLang: Unmatched map value. All maps must have a value to map to the key");
        }
        for(i in 0...typeAndExprs.length) {
          var varType: String = alphabet[i];
          var varName: String = varType.toLowerCase();
          var typeAndExpr: Dynamic = typeAndExprs[i];
          var uniqueVarType: String = varTypeMap.get(typeAndExpr.type);
          exprs.push({ expr: EVars([{ expr: { expr: ECall({ expr: EConst(CIdent(uniqueVarType)), pos: MacroContext.currentPos() },[typeAndExpr.expr]), pos: MacroContext.currentPos() }, name: varName, type: TPath({ name: 'EitherEnums', sub: 'Either${numberOfElements}', pack: [], params: allTypes }) }]), pos: MacroContext.currentPos() });

          if(a == null) {
            a = {expr: EConst(CIdent(varName)), pos: MacroContext.currentPos()};
          } else if(b == null) {
            b = {expr: EConst(CIdent(varName)), pos: MacroContext.currentPos()};
          }

          if(a != null && b != null) {
            eitherArray.push({ expr: ECall({ expr: EField({ expr: EConst(CIdent('map')), pos: MacroContext.currentPos() },'set'), pos: MacroContext.currentPos() },
            [a,b]), pos: MacroContext.currentPos() });
            a = null;
            b = null;
          }
        }
        var eitherType = { name: 'EitherEnums', sub: 'Either${numberOfElements}', pack: [], params: allTypes };
        var newMap = { expr: EVars([{ expr: { expr: ENew({ name: "Map", pack: [], params: [TPType(TPath(eitherType)),TPType(TPath(eitherType))] },[]), pos: MacroContext.currentPos() }, name: "map", type: TPath({ name: "Map", pack: [], params: [TPType(TPath(eitherType)),TPType(TPath(eitherType))] }) }]), pos: MacroContext.currentPos() }
        exprs.push(newMap);
        for(either in eitherArray) {
          exprs.push(macro $e{either});
        }
        var newMap = macro {
          map;
        };
        exprs.push(Macros.extractBlock(newMap)[0]);
        MacroLogger.logExpr(macro $b{exprs}, "genMap expr");
        return macro $b{exprs};
      case _:
        throw "EitherMacro.getMap(): gen setup return has changed, this shouldn't happen accidentally!";
    }
  }

  private static function setup(values: Expr):Array<Dynamic> {
    var p: Printer = new Printer();
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
          findTypesAndExprs(typeAndExprs, a);
          findTypesAndExprs(typeAndExprs, b);
        case _:
          findTypesAndExprs(typeAndExprs, vExpr);
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

  private static function findTypesAndExprs(typeAndExprs: Array<Dynamic>, vExpr: Expr): Void {
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
            var expr: Expr = Macros.haxeToExpr('Tuple.create([Atom.create("var"), "${ident}"])');
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
        typeAndExprs.push({type: {expr: EConst(CIdent(type)), pos: MacroContext.currentPos()}, expr: vExpr});
      case {expr: EBinop(op, e1, e2)}:
        for(expr in [e1, e2]) {
          findTypesAndExprs(typeAndExprs, expr);
        }
      case {expr: expr}:
        findTypesAndExprs(typeAndExprs, {expr: Reflect.field(expr, 'expr'), pos: MacroContext.currentPos()});
      case e:
        MacroLogger.log(e, 'e');
    }
  }
}