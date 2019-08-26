package lang.macros;
import lang.macros.MacroTools;
import lang.macros.MacroTools;
import hscript.plus.ParserPlus;
import haxe.macro.Printer;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;
class PatternMatch {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  macro public static function match(pattern: Expr, valueExpr: Expr): Expr {
    MacroLogger.log("===============================");
    MacroLogger.log("PatternMatch", 'PatternMatch');

    var expr: Expr = generatePatternMatch(pattern, valueExpr);

    var retVal = macro {
      var scope: Map<String, Dynamic> = new Map<String, Dynamic>();
      while(true) {
        $e{expr}
        break;
      }
      scope;
    }

    MacroLogger.logExpr(retVal, 'retVal');
    return retVal;
  }

  #if macro
  public static function generatePatternMatch(pattern: Expr, valueExpr: Expr):Expr {
    return switch(pattern.expr) {
      case EConst(CIdent(v)):
        var varName: Dynamic = v;
        var value: Dynamic = printer.printExpr(valueExpr);
        var haxeStr: String = 'scope.set("${varName}", ${value});';
        var expr: Expr = Macros.haxeToExpr(haxeStr);
        macro $e{expr};
      case EConst(CString(_)) | EConst(CInt(_)) | EConst(CFloat(_)):
        valuesNotEqual(pattern, valueExpr);
      case ECall({expr: EField({expr: EConst(CIdent("Atom"))}, _)}, [{expr: EConst(CString(_))}]):
        valuesNotEqual(pattern, valueExpr);
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, _)}, [{expr: ECall(_, [{expr: ECast({expr: EArrayDecl(values)}, _)}])}]):
        var individualMatches: Array<Expr> = [];
        var counter: Int = 0;
        for(v in values) {
          var strExpr: String = 'lang.EitherSupport.getValue(arrayTuple[${counter}])';
          var expr: Expr = generatePatternMatch(v, Macros.haxeToExpr(strExpr));
          individualMatches.push(expr);
          counter++;
        }
        var individualMatchesBlock: Expr = MacroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }

        var tupleLength: Expr = Macros.haxeToExpr('${values.length}');
        macro
          if(!Std.is($e{valueExpr}, Tuple)) {
            scope = null;
            break;
          } else {
            if($e{tupleLength} != Tuple.length($e{valueExpr})) {
              scope = null;
              break;
            } else {
              var arrayTuple = Tuple.array($e{valueExpr});
              $e{individualMatchesBlock}
            }
          }
        ;
      case e:
        MacroLogger.log(e, 'expr');
        macro null;
    }
  }

  public static inline function valuesNotEqual(pattern: Expr, valueExpr: Expr):Expr {
    return macro
      if($e{pattern} != $e{valueExpr}) {
        scope = null;
        break;
      }
    ;
  }

  #end
}