package;

import lang.macros.MacroLogger;
import haxe.macro.Context;
import haxe.macro.Expr;
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
    var p: Printer = new Printer();
    var valueExpressions: Array<Dynamic> = switch(values) {
      case {expr: ECast({expr: EArrayDecl(expr)}, _)}:
        expr;
      case _:
        MacroLogger.log(values);
        throw 'Either was unable to match type: Unsupported match';
    }

    var typeAndExprs: Array<Dynamic> = [];
    for(valueExpression in valueExpressions) {
      var vExpr: Expr = cast valueExpression;
      switch(vExpr) {
        case {expr: EConst(val)}:
          switch(val) {
            case CInt(value):
              typeAndExprs.push({type: "Int", expr: vExpr});
            case CString(value):
              typeAndExprs.push({type: "String", expr: vExpr});
            case CFloat(value):
              typeAndExprs.push({type: "Float", expr: vExpr});
            case _:
          }
        case {expr: ECall(val, _fun)}:
          switch(val) {
            case {expr: EField({expr: EConst(CString(_))}, _)}:
              typeAndExprs.push({type: "Atom", expr: vExpr});
            case {expr: EField({expr: EConst(CIdent(type))}, _)}:
              typeAndExprs.push({type: '${type}', expr: vExpr});
            case _:
          }
        case {expr: ENew({name: type}, _args)}:
          typeAndExprs.push({type: {expr: EConst(CIdent(type)), pos: Context.currentPos()}, expr: vExpr});
        case _:
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

    var eitherArray: Array<Expr> = [];
    var exprs: Array<Expr> = [];
    for(i in 0...valueExpressions.length) {
      var varType: String = alphabet[i];
      var varName: String = varType.toLowerCase();
      var typeAndExpr: Dynamic = typeAndExprs[i];
      var uniqueVarType: String = varTypeMap.get(typeAndExpr.type);
      exprs.push({ expr: EVars([{ expr: { expr: ECall({ expr: EConst(CIdent(uniqueVarType)), pos: Context.currentPos() },[typeAndExpr.expr]), pos: Context.currentPos() }, name: varName, type: TPath({ name: 'EitherEnums', sub: 'Either${numberOfElements}', pack: [], params: allTypes }) }]), pos: Context.currentPos() });
      eitherArray.push({expr: EConst(CIdent(varName)), pos: Context.currentPos()});
    }
    exprs.push(macro $a{eitherArray});
    return macro $b{exprs};
  }

}