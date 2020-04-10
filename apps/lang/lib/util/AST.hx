package util;
import haxe.macro.Expr.ExprDef;
import hscript.Macro;
import hscript.Parser;
class AST {
  public static inline function getModuleInfo(moduleCode: String):Tuple {
    var parser: Parser = new Parser();
    parser.allowMetadata = true;
    parser.allowTypes = true;
    var ast = parser.parseString(moduleCode);
    var pos = { max: 12, min: 0, file: null };
    var ast = new Macro(pos).convert(ast);

    return switch(ast.expr) {
      case ECall({expr: EConst(CIdent(type))}, args):
        var moduleExpr = args[0];
        switch(moduleExpr.expr) {
          case EConst(CIdent(moduleName)):
            var moduleType: String = getType(type);
            if(moduleType == null) {
              Tuple.create([Atom.create('error'), 'Invalid module type']);
            } else {
              Tuple.create([Atom.create('ok'), moduleName, moduleType]);
            }
          case _:
            Tuple.create([Atom.create('error'), 'Invalid module declaration']);
        }
      case _:
        Tuple.create([Atom.create('error'), 'Invalid macro function call']);
    }
  }

  private static inline function getType(type:String):String {
    return switch type {
      case "defmodule":
        'module';
      case "deftype":
        'type';
      case "defapi":
        'api';
      case "set_iface":
        'iface';
      case _:
        null;
    }
  }
}
