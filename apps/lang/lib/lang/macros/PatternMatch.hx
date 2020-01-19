package lang.macros;
import lang.macros.MacroTools;
import haxe.macro.Expr;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
using haxe.macro.Tools;
import haxe.macro.Expr;

class PatternMatch {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  public static function match(pattern: Expr, valueExpr: Expr): Expr {
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

  public static function generatePatternMatch(pattern: Expr, valueExpr: Expr):Expr {
    return switch(pattern.expr) {
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, "create")}, [{expr: EArrayDecl([{expr: ECall({ expr: EField({ expr: EConst(CIdent('Atom')) },'create') }, [{ expr: EConst(CString('const')) }]) }, value])}]):
        generatePatternMatch(value, valueExpr);
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, "create")}, [{expr: EArrayDecl([{expr: ECall({ expr: EField({ expr: EConst(CIdent('Atom')) },'create') }, [{ expr: EConst(CString('var')) }]) }, { expr: EConst(CString(varName)) }])}]):
        var value = { expr: EConst(CIdent(varName)), pos: MacroContext.currentPos() }
        generatePatternMatch(value, valueExpr);
      case EConst(CIdent(v)):
        var varName: Dynamic = v;
        var value: Dynamic = printer.printExpr(valueExpr);
        var haxeStr: String = 'scope.set("${varName}", ${value});';
        var expr: Expr = lang.macros.Macros.haxeToExpr(haxeStr);
        expr;
      case EConst(CString(_)) | EConst(CInt(_)) | EConst(CFloat(_)):
        valuesNotEqual(pattern, valueExpr);
      case ECall({expr: EField({expr: EConst(CIdent("Atom"))}, _)}, [{expr: EConst(CString(_))}]):
        valuesNotEqual(pattern, valueExpr);
      case ECall({ expr: EField({ expr: EField({ expr: EConst(CIdent('lang')) },'EitherSupport') },'getValue') },params):
        MacroLogger.log(params, 'params');
        macro null;
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, _)}, [{expr: EArrayDecl(values)}]):
        var individualMatches: Array<Expr> = [];
        var counter: Int = 0;
        for(v in values) {
          var strExpr: String = 'lang.EitherSupport.getValue(arrayTuple[${counter}])';
          var expr: Expr = generatePatternMatch(v, lang.macros.Macros.haxeToExpr(strExpr));
          individualMatches.push(expr);
          counter++;
        }
        var individualMatchesBlock: Expr = MacroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }

        var tupleLength: Expr = lang.macros.Macros.haxeToExpr('${values.length}');
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
      case ECall({expr: EField({expr: EConst(CIdent("LList"))}, _)}, [{expr: EArrayDecl([{expr: EBinop(OpOr, head, tail)}])}]):
        var individualMatches: Array<Expr> = [];
        var strExpr: String = 'lang.EitherSupport.getValue(LList.hd(rhsList))';
        var expr: Expr = generatePatternMatch(head, lang.macros.Macros.haxeToExpr(strExpr));
        individualMatches.push(expr);
        var strExpr: String = 'lang.EitherSupport.getValue(LList.tl(rhsList))';
        var expr: Expr = generatePatternMatch(tail, lang.macros.Macros.haxeToExpr(strExpr));
        individualMatches.push(expr);
        var individualMatchesBlock: Expr = MacroTools.buildBlock(individualMatches);
        macro {
          var rhsList: LList = $e{valueExpr};
          $e{individualMatchesBlock};
          break;
        }
      case ECall({expr: EField({expr: EConst(CIdent("LList"))}, _)}, [{expr: EArrayDecl(values)}]):
        var individualMatches: Array<Expr> = [];
        var counter: Int = 0;
        for(v in values) {
          var strExpr: String = 'lang.EitherSupport.getValue(LList.hd(rhsList))';
          var expr: Expr = generatePatternMatch(v, lang.macros.Macros.haxeToExpr(strExpr));
          individualMatches.push(expr);
          var assignTail: String = 'rhsList = LList.tl(rhsList)';
          individualMatches.push(lang.macros.Macros.haxeToExpr(assignTail));
          counter++;
        }
        individualMatches.pop(); //remove the last tail assigment, it's unnecessary.
        var individualMatchesBlock: Expr = MacroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }
        var listLength: Expr = lang.macros.Macros.haxeToExpr('${values.length}');
        var expr = macro {
          if(!Std.is($e{valueExpr}, LList)) {
            scope = null;
            break;
          } else {
            if(LList.length($e{valueExpr}) != $e{listLength}) {
              scope = null;
              break;
            }
            var rhsList: LList = $e{valueExpr};
            $e{individualMatchesBlock}
          }
        }
        return expr;
      case ECall({expr: EField({expr: EConst(CIdent("MMap"))}, _)}, [{expr: EBlock(values)}]):
        // map key
        var individualMatches: Array<Expr> = [];
        var isKey: Bool = true;
        var key: String = null;
        for(value in values) {
          switch(value.expr) {
            case EVars([v]):
              MacroLogger.logExpr(v.expr, 'v');
              if(isKey) {
                key = printer.printExpr(v.expr);
                var strExpr: String = 'MMap.hasKey(${printer.printExpr(valueExpr)}, ArgHelper.extractArgValue(${key}, ____scopeVariables))';
                var expr: Expr = generatePatternMatch(lang.macros.Macros.haxeToExpr('Atom.create("true")'), lang.macros.Macros.haxeToExpr(strExpr));
                individualMatches.push(expr);
              } else {
                var value = printer.printExpr(v.expr);
                MacroLogger.log(value, 'value');
                MacroLogger.log(key, 'key');
                var strExpr: String = 'lang.EitherSupport.getValue(MMap.get(${printer.printExpr(valueExpr)}, ArgHelper.extractArgValue(${key}, ____scopeVariables)))';
                var expr: Expr = generatePatternMatch(v.expr, lang.macros.Macros.haxeToExpr(strExpr));
                individualMatches.push(expr);
              }
              isKey = !isKey;
            case EArrayDecl(_):
            case e:
              MacroLogger.logExpr(value, 'value');
              throw new ParsingException('AnnaLang: Expected EVar, got ${e}');
          }
        }
        var individualMatchesBlock: Expr = MacroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }
        macro {
          if(!Std.is($e{valueExpr}, MMap)) {
            scope = null;
            break;
          }
          $e{individualMatchesBlock};
        }
      case EBinop(OpMod, type, {expr: EObjectDecl(args)}):
        var individualMatches: Array<Expr> = [];
        for(arg in args) {
          var strExpr: String = 'Reflect.field(${printer.printExpr(valueExpr)}, "${arg.field}")';
          var expr: Expr = generatePatternMatch(arg.expr, lang.macros.Macros.haxeToExpr(strExpr));
          individualMatches.push(expr);
        }
        var individualMatchesBlock: Expr = MacroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }
        macro {
          if(!Std.is($e{valueExpr}, $e{type})) {
            scope = null;
            break;
          }
          $e{individualMatchesBlock};
        }
      case EBlock([base, suffix]):
        var valueStr: String = '${printer.printExpr(valueExpr)}.substring(${printer.printExpr(base)}.length)';
        var exprMatch: Expr = generatePatternMatch(suffix, Macros.haxeToExpr(valueStr));
        macro {
          for(i in 0...$e{base}.length) {
            if($e{base}.charAt(i) != $e{valueExpr}.charAt(i)) {
              scope = null;
              break;
            }
          }
          if(scope == null) {
            break;
          }
          $e{exprMatch};
          break;
        }
      case EObjectDecl(values):
        var individualMatches: Array<Expr> = [];
        for(value in values) {
          MacroLogger.log(values, 'values');
          var strExpr: String = '';
          strExpr = 'Keyword.hasKey(${printer.printExpr(valueExpr)}, ${value.field})';
          var expr: Expr = generatePatternMatch(lang.macros.Macros.haxeToExpr('Atom.create("true")'), lang.macros.Macros.haxeToExpr(strExpr));
          individualMatches.push(expr);

          strExpr = 'Keyword.get(${printer.printExpr(valueExpr)}, ${value.field})';
          var expr: Expr = generatePatternMatch(value.expr, lang.macros.Macros.haxeToExpr(strExpr));
          individualMatches.push(expr);
        }
        var individualMatchesBlock: Expr = MacroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }
        var expr = macro {
          if(!Std.is($e{valueExpr}, Keyword)) {
            scope = null;
            break;
          }
          $e{individualMatchesBlock};
        }
        expr;
      case ECall({expr: EField({expr: EConst(CIdent("Keyword"))}, _)}, values):
        var individualMatches: Array<Expr> = [];
        for(value in values) {
          switch(value.expr) {
            case EArrayDecl(exprs):
              for(expr in exprs) {
                switch(expr.expr) {
                  case EArrayDecl([field, assign]):
                    var strExpr: String = '';
                    strExpr = 'Keyword.hasKey(${printer.printExpr(valueExpr)}, ${printer.printExpr(field)})';
                    var expr: Expr = generatePatternMatch(lang.macros.Macros.haxeToExpr('Atom.create("true")'), lang.macros.Macros.haxeToExpr(strExpr));
                    individualMatches.push(expr);

                    strExpr = 'Keyword.get(${printer.printExpr(valueExpr)}, ${printer.printExpr(field)})';
                    var expr: Expr = generatePatternMatch(assign, lang.macros.Macros.haxeToExpr(strExpr));
                    individualMatches.push(expr);

                  case _:
                    throw new ParsingException("AnnaLang: Unexpected syntax. Expects: @keyword{foo: 'bar', baz: 'cat'}");

                }
              }
            case _:
              throw new ParsingException("AnnaLang: Unexpected syntax. Expects: @keyword{foo: 'bar', baz: 'cat'}");
          }
        }
        var individualMatchesBlock: Expr = MacroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }
        var expr = macro {
          if(!Std.is($e{valueExpr}, Keyword)) {
            scope = null;
            break;
          }
          $e{individualMatchesBlock};
        }
        MacroLogger.logExpr(expr, 'expr');
        expr;
      case EMeta(_):
        MacroLogger.logExpr(pattern, 'pattern');
        var typeAndValue = MacroTools.getTypeAndValue(pattern);
        MacroLogger.log(typeAndValue, 'PatternMatch typeAndValue');
        var expr = Macros.haxeToExpr(typeAndValue.value);
        generatePatternMatch(expr, valueExpr);
      case EBinop(OpArrow, base, suffix):
        var valueStr: String = '${printer.printExpr(valueExpr)}.substring(${printer.printExpr(base)}.length)';
        var exprMatch: Expr = generatePatternMatch(suffix, Macros.haxeToExpr(valueStr));
        macro {
          for(i in 0...$e{base}.length) {
            if($e{base}.charAt(i) != $e{valueExpr}.charAt(i)) {
              scope = null;
              break;
            }
          }
          if(scope == null) {
            break;
          }
          $e{exprMatch};
          break;
        }
      case e:
        MacroLogger.log(e, 'PatternMatch expr');
        MacroLogger.logExpr(pattern, 'PatternMatch expr');
        MacroLogger.log(valueExpr, 'PatternMatch expr');
        MacroLogger.logExpr(valueExpr, 'PatternMatch expr');
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

}