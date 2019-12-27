package util;
import hscript.Macro;
import hscript.Parser;
class AST {
  public static inline function getModuleName(moduleCode: String):Tuple {
    var parser: Parser = new Parser();
    parser.allowMetadata = true;
    parser.allowTypes = true;
    var ast = parser.parseString(moduleCode);
    var pos = { max: 12, min: 0, file: null };
    var ast = new Macro(pos).convert(ast);

    return switch(ast.expr) {
      case ECall({expr: EConst(CIdent('defCls'))}, args) | ECall({expr: EConst(CIdent('defType'))}, args) | ECall({expr: EConst(CIdent('defApi'))}, args):
        var moduleExpr = args[0];
        switch(moduleExpr.expr) {
          case EConst(CIdent(moduleName)):
            Tuple.create([Atom.create('ok'), moduleName]);
          case _:
            Tuple.create([Atom.create('error'), 'Invalid module declaration']);
        }
      case _:
        Tuple.create([Atom.create('error'), 'Invalid macro function call']);
    }
  }
}
