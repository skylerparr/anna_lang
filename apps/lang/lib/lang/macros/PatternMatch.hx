package lang.macros;
import lang.macros.AnnaLang;
import lang.macros.MacroTools;
import lang.macros.MacroTools;
import haxe.macro.Expr;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
using haxe.macro.Tools;

class PatternMatch {
  public static function match(annaLang: AnnaLang, pattern: Expr, valueExpr: Expr): Expr {
    var expr: Expr = generatePatternMatch(annaLang, pattern, valueExpr);

    var retVal = macro {
      var scope: haxe.ds.StringMap<Dynamic> = new haxe.ds.StringMap();
      trace(scope);
      while(true) {
        $e{expr}
        break;
      }
      trace(scope);
      scope;
    }
    return retVal;
  }

  public static function generatePatternMatch(annaLang: AnnaLang, pattern: Expr, valueExpr: Expr, counter: Int = 0):Expr {
    var macroContext: MacroContext = annaLang.macroContext;
    var macros: Macros = annaLang.macros;
    var macroTools: MacroTools = annaLang.macroTools;
    var printer: Printer = annaLang.printer;

    return switch(pattern.expr) {
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, "create")}, [{expr: EArrayDecl([{expr: ECall({ expr: EField({ expr: EConst(CIdent('Atom')) },'create') }, [{ expr: EConst(CString('const')) }]) }, value])}]):
        generatePatternMatch(annaLang, value, valueExpr);
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, "create")}, [{expr: EArrayDecl([{expr: ECall({ expr: EField({ expr: EConst(CIdent('Atom')) },'create') }, [{ expr: EConst(CString('var')) }]) }, { expr: EConst(CString(varName)) }])}]):
        var value = { expr: EConst(CIdent(varName)), pos: macroContext.currentPos() }
        generatePatternMatch(annaLang, value, valueExpr);
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, "create")}, [{expr: EArrayDecl([{expr: ECall({ expr: EField({ expr: EConst(CIdent('Atom')) },'create') }, [{ expr: EConst(CString('pinned')) }]) }, { expr: EConst(CString(varName)) }])}]):
        var haxeStr: String = 'arrayTuple[${counter}] = scopeVariables.get("${varName}"); lang.EitherSupport.getValue(arrayTuple[${counter}]);';
        macros.haxeToExpr(haxeStr);
      case EConst(CIdent(v)):
        var varName: Dynamic = v;
        var value: Dynamic = printer.printExpr(valueExpr);
        var haxeStr: String = 'scope.set("${varName}", ${value});';
        var expr: Expr = macros.haxeToExpr(haxeStr);
        expr;
      case EConst(CString(_)) | EConst(CInt(_)) | EConst(CFloat(_)):
        valuesNotEqual(pattern, valueExpr);
      case ECall({expr: EField({expr: EConst(CIdent("Atom"))}, _)}, [{expr: EConst(CString(_))}]):
        valuesNotEqual(pattern, valueExpr);
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, _)}, [{expr: EArrayDecl(values)}]) | EArrayDecl(values):
        var individualMatches: Array<Expr> = [];
        var counter: Int = 0;
        for(patternExpr in values) {
          var strExpr: String = 'lang.EitherSupport.getValue(arrayTuple[${counter}])';
          var expr: Expr = generatePatternMatch(annaLang, patternExpr, macros.haxeToExpr(strExpr), counter);
          individualMatches.push(expr);
          counter++;
        }
        var individualMatchesBlock: Expr = macroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }

        var tupleLength: Expr = macros.haxeToExpr('${values.length}');
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
              scope.set("$$$", Tuple.create(arrayTuple));
            }
          }
        ;
      case ECall({expr: EField({expr: EConst(CIdent("LList"))}, _)}, [{expr: EArrayDecl([{expr: EBinop(OpOr, head, tail)}])}]):
        var individualMatches: Array<Expr> = [];
        var patternExpr: Expr = macro lang.EitherSupport.getValue(LList.hd(rhsList));
        var expr: Expr = generatePatternMatch(annaLang, head, patternExpr);
        individualMatches.push(expr);
        var patternExpr: Expr = macro lang.EitherSupport.getValue(LList.tl(rhsList));
        var expr: Expr = generatePatternMatch(annaLang, tail, patternExpr);
        individualMatches.push(expr);
        var individualMatchesBlock: Expr = macroTools.buildBlock(individualMatches);
        macro {
          var rhsList: LList = $e{valueExpr};
          $e{individualMatchesBlock};
          break;
        }
      case ECall({expr: EField({expr: EConst(CIdent("LList"))}, _)}, [{expr: EArrayDecl(values)}]):
        var individualMatches: Array<Expr> = [];
        var counter: Int = 0;
        for(v in values) {
          var strExpr: Expr = macro lang.EitherSupport.getValue(LList.hd(rhsList));
          var expr: Expr = generatePatternMatch(annaLang, v, strExpr);
          individualMatches.push(expr);
          var assignTail: Expr = macro rhsList = LList.tl(rhsList);
          individualMatches.push(assignTail);
          counter++;
        }
        individualMatches.pop(); //remove the last tail assigment, it's unnecessary.
        var individualMatchesBlock: Expr = macroTools.buildBlock(individualMatches);
        if(individualMatchesBlock == null) {
          individualMatchesBlock = macro {};
        }
        var listLength: Expr = macroTools.buildConst(CInt(values.length + ""));
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
              if(isKey) {
                key = printer.printExpr(v.expr);
                var strExpr: String = 'MMap.hasKey(${printer.printExpr(valueExpr)}, ArgHelper.extractArgValue(${key}, scopeVariables, Code.annaLang))';
                var expr: Expr = generatePatternMatch(annaLang, macros.haxeToExpr('Atom.create("true")'), macros.haxeToExpr(strExpr));
                individualMatches.push(expr);
              } else {
                var value = printer.printExpr(v.expr);
                MacroLogger.log(value, 'value');
                MacroLogger.log(key, 'key');
                var strExpr: String = 'lang.EitherSupport.getValue(MMap.get(${printer.printExpr(valueExpr)}, ArgHelper.extractArgValue(${key}, scopeVariables, Code.annaLang)))';
                var expr: Expr = generatePatternMatch(annaLang, v.expr, macros.haxeToExpr(strExpr));
                individualMatches.push(expr);
              }
              isKey = !isKey;
            case EArrayDecl(_):
            case e:
              MacroLogger.logExpr(value, 'value');
              throw new ParsingException('AnnaLang: Expected EVar, got ${e}');
          }
        }
        var individualMatchesBlock: Expr = macroTools.buildBlock(individualMatches);
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
          var expr: Expr = generatePatternMatch(annaLang, arg.expr, macros.haxeToExpr(strExpr));
          individualMatches.push(expr);
        }
        var individualMatchesBlock: Expr = macroTools.buildBlock(individualMatches);
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
        var exprMatch: Expr = generatePatternMatch(annaLang, suffix, macros.haxeToExpr(valueStr));
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
          var strExpr: String = '';
          strExpr = 'Keyword.hasKey(${printer.printExpr(valueExpr)}, ${value.field})';
          var expr: Expr = generatePatternMatch(annaLang, macroTools.getAtomExpr("true"), macros.haxeToExpr(strExpr));
          individualMatches.push(expr);

          strExpr = 'Keyword.get(${printer.printExpr(valueExpr)}, ${value.field})';
          var expr: Expr = generatePatternMatch(annaLang, value.expr, macros.haxeToExpr(strExpr));
          individualMatches.push(expr);
        }
        var individualMatchesBlock: Expr = macroTools.buildBlock(individualMatches);
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
                    var expr = macro Keyword.hasKey($e{valueExpr}, $e{field});
                    expr = generatePatternMatch(annaLang, macroTools.getAtomExpr("true"), expr);
                    individualMatches.push(expr);

                    expr = macro Keyword.get($e{valueExpr}, $e{field});
                    expr = generatePatternMatch(annaLang, assign, expr);
                    individualMatches.push(expr);

                  case _:
                    throw new ParsingException("AnnaLang: Unexpected syntax. Expects: @keyword{foo: 'bar', baz: 'cat'}");

                }
              }
            case _:
              throw new ParsingException("AnnaLang: Unexpected syntax. Expects: @keyword{foo: 'bar', baz: 'cat'}");
          }
        }
        var individualMatchesBlock: Expr = macroTools.buildBlock(individualMatches);
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
        var typeAndValue = macroTools.getTypeAndValue(pattern);
        var expr = macros.haxeToExpr(typeAndValue.value);
        generatePatternMatch(annaLang, expr, valueExpr);
      case EBinop(OpArrow, base, suffix):
        var valueStr: String = '${printer.printExpr(valueExpr)}.substring(len)';
        var exprMatch: Expr = generatePatternMatch(annaLang, suffix, macros.haxeToExpr(valueStr));
        macro {
          var len: Int = $e{base}.length;
          var i: Int = 0;
          var str: String = $e{valueExpr};
          while(i < len) {
            if($e{base}.charAt(i) != str.charAt(i)) {
              scope = null;
              break;
            }
            ++i;
          }
          if(scope == null) {
            break;
          }
          $e{exprMatch};
          break;
        }
      case e:
        MacroLogger.log(e, 'PatternMatch e');
        MacroLogger.logExpr(pattern, 'PatternMatch pattern');
        MacroLogger.log(valueExpr, 'PatternMatch valueExpr');
        MacroLogger.logExpr(valueExpr, 'PatternMatch valueExpr');
        throw new ParsingException("AnnaLang: Unexpected pattern match");
        macro null;
    }
  }

  public static inline function valuesNotEqual(pattern: Expr, valueExpr: Expr):Expr {
    return macro
      if($e{pattern} != $e{valueExpr}) {
        trace("ne");
        trace($e{pattern}, "is not equal");
        scope = null;
        break;
      }
    ;
  }

}
