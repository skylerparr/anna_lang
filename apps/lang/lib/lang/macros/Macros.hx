package lang.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import lang.macros.MacroLogger;
import haxe.macro.Expr;
using haxe.macro.Tools;

//  =>
// #pos\(.*?\)
class Macros {

  private var macroContext: MacroContext;
  private var printer: Printer;
  private var annaLang: AnnaLang;

  public function new(annaLang: AnnaLang) {
    this.annaLang = annaLang;
    macroContext = annaLang.macroContext;
    printer = annaLang.printer;
  }

  macro public static function build(): Array<Field> {
    var macros: Macros = AnnaLang.annaLangForMacro.macros;
    var fields: Array<Field> = Context.getBuildFields();
    var retFields: Array<Field> = [];
    for(field in fields) {
      var newField: Field = macros.updateField(field);
      retFields.push(newField);
    }
    MacroLogger.log("---------------------");
    MacroLogger.log('${Context.getLocalType()}');
    MacroLogger.printFields(retFields);
    MacroLogger.log("_____________________");
    return retFields;
  }

  private function updateField(field: Field): Field {
    return switch(field.kind) {
      case FVar(_, null):
        field;
      case FVar(fvar, e):
        switch(e.expr) {
          case EBlock(blk):
            var metaInBlock: Array<Expr> = [];
            for(expr in blk) {
              var e = findMetaInBlock(expr, null);
              metaInBlock.push(e);
            }
            var eblock = EBlock(metaInBlock);
            field.kind = FVar(fvar, {expr: eblock, pos: macroContext.currentPos()});
            field;
          case EMeta(entry, expr):
            var metaBlock = extractMeta(entry, expr, null);
            field.kind = FVar(fvar, metaBlock);
            field;
          case _:
            field;
        }
      case FFun(ffun):
        var exprs = extractBlock(ffun.expr);
        var retValExprs: Array<Expr> = [];
        for(expr in exprs) {
          var e = findMetaInBlock(expr, null);
          switch(e.expr) {
            case EBlock(blk):
              for(expr in blk) {
                retValExprs.push(expr);
              }
            case _:
              retValExprs.push(e);
          }
        }
        ffun.expr = {expr: EBlock(retValExprs), pos: macroContext.currentPos()};
        field.kind = FFun(ffun);
        field;
      case FProp(get, set, t, e):
        field;
    }
  }

  private function findMetaInBlock(expr: Expr, rhs: Expr):Expr {
    if(expr == null) {
      return expr;
    }

    var retValBlock: Array<Expr> = [];
    switch(expr.expr) {
      case ECall(ecall, params):
        var valueBlocks: Array<Expr> = [];
        for(param in params) {
          var meta = findMetaInBlock(param, rhs);
          valueBlocks.push(meta);
        }
        retValBlock.push({expr: ECall(ecall, valueBlocks), pos: macroContext.currentPos()});
      case EMeta(entry, expr):
        return handleMeta(entry, expr, rhs);
      case ENew(enew, params):
        var valueBlocks: Array<Expr> = [];
        for(param in params) {
          var meta = findMetaInBlock(param, rhs);
          valueBlocks.push(meta);
        }
        retValBlock.push({expr: ENew(enew, valueBlocks), pos: macroContext.currentPos()});
      case EArrayDecl(values):
        var valueBlocks: Array<Expr> = [];
        for(value in values) {
          var meta = findMetaInBlock(value, rhs);
          valueBlocks.push(meta);
        }
        retValBlock.push({expr: EArrayDecl(valueBlocks), pos: macroContext.currentPos()});
      case EField(fieldExpr, field):
        retValBlock.push(expr);
      case EVars(vars):
        var retVars: Array<Var> = [];
        for(v in vars) {
          var meta = findMetaInBlock(v.expr, rhs);
          v.expr = meta;
          retVars.push(v);
        }
        retValBlock.push(expr);
      case EBinop(_, _, _):
         handleBinop(expr, rhs, retValBlock);
      case EFunction(name, func):
        var bodyExpr = func.expr;
        var meta = findMetaInBlock(bodyExpr, null);
        func.expr = meta;
        retValBlock.push(expr);
      case EBlock(exprs):
        var updatedMeta: Array<Expr> = [];
        for(expr in exprs) {
          var meta = findMetaInBlock(expr, null);
          updatedMeta.push(meta);
        }
        retValBlock.push({expr: EBlock(updatedMeta), pos: macroContext.currentPos()});
      case EIf(econd, eif, eelse):
        var econdMeta = findMetaInBlock(econd, null);
        var eifMeta = findMetaInBlock(eif, null);
        var eelseMeta = findMetaInBlock(eelse, null);
        retValBlock.push({expr: EIf(econdMeta, eifMeta, eelseMeta), pos: macroContext.currentPos()});
      case EArray(e1, e2):
        retValBlock.push(expr);
      case EBreak:
        throw "AnnaLang: Unimplemented case";
      case ECast(e, t):
        retValBlock.push(expr);
      case ECheckType(e, t):
        throw "AnnaLang: Unimplemented case";
      case EConst(c):
        retValBlock.push(expr);
      case EContinue:
        throw "AnnaLang: Unimplemented case";
      case EDisplay(e, displayKind):
        throw "AnnaLang: Unimplemented case";
      case EDisplayNew(t):
        throw "AnnaLang: Unimplemented case";
      case EFor(it, expr):
        var haxeStr: String = 'for(${printer.printExpr(it)}) {
          ${printer.printExpr(expr)}
        }';
        retValBlock.push(haxeToExpr(haxeStr));
//      case EIn(e1, e2):
//        throw "AnnaLang: Unimplemented case";
      case EObjectDecl(fields):
        var keyValues: Array<{field:String, expr:Expr, quotes: Null<QuoteStatus>}> = [];
        for(item in fields) {
          var expr = findMetaInBlock(item.expr, null);
          keyValues.push({field: item.field, expr: expr, quotes: null});
        }
        retValBlock.push({expr: EObjectDecl(keyValues), pos: macroContext.currentPos()});
      case EParenthesis(e):
        retValBlock.push(expr);
      case EReturn(e):
        var eReturnMeta = findMetaInBlock(e, null);
        retValBlock.push({expr: EReturn(eReturnMeta), pos: macroContext.currentPos()});
      case ESwitch(e, cases, edef):
        retValBlock.push(expr);
      case ETernary(econd, eif, eelse):
        throw "AnnaLang: Unimplemented case";
      case EThrow(e):
        retValBlock.push(expr);
      case ETry(e, catches):
        throw "AnnaLang: Unimplemented case";
      case EUnop(op, postFix, e):
        retValBlock.push(expr);
      case EUntyped(e):
         throw "AnnaLang: Unimplemented case";
      case EWhile(econd, e, normalWhile):
        retValBlock.push(expr);
    }
    if(retValBlock.length == 1) {
      return retValBlock[0];
    } else {
      var block: Expr = {expr: EBlock(retValBlock), pos: macroContext.currentPos()};
      return block;
    }
  }

  private function handleBinop(expr: Expr, rhs: Expr, retValBlock: Array<Expr>):Void {
    switch(expr.expr) {
      case EBinop(OpArrow, a, b):
        var meta = findMetaInBlock(a, rhs);
        retValBlock.push(meta);

        meta = findMetaInBlock(b, rhs);
        retValBlock.push(meta);
      case EBinop(OpAssign, a, b):
        var metaB = findMetaInBlock(b, rhs);
        var metaA = findMetaInBlock(a, rhs);

        retValBlock.push({expr: EBinop(OpAssign, metaA, metaB), pos: macroContext.currentPos()});
      case EBinop(OpEq, a, b):
        var meta = findMetaInBlock(a, b);
        retValBlock.push(meta);
      case EBinop(OpAdd, a, b):
        var metaB = findMetaInBlock(b, rhs);
        var metaA = findMetaInBlock(a, rhs);
        retValBlock.push({expr: EBinop(OpAdd, metaA, metaB), pos: macroContext.currentPos()});
      case EBinop(OpAnd, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpBoolAnd, a, b):
        var metaB = findMetaInBlock(b, rhs);
        var metaA = findMetaInBlock(a, rhs);

        retValBlock.push({expr: EBinop(OpBoolAnd, metaA, metaB), pos: macroContext.currentPos()});
      case EBinop(OpBoolOr, a, b):
        var metaB = findMetaInBlock(b, rhs);
        var metaA = findMetaInBlock(a, rhs);

        retValBlock.push({expr: EBinop(OpBoolOr, metaA, metaB), pos: macroContext.currentPos()});
      case EBinop(OpDiv, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpGt, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpGte, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpInterval, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpLt, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpLte, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpMod, a, b):
        var metaB = findMetaInBlock(b, rhs);
        retValBlock.push({expr: EBinop(OpMod, a, metaB), pos: macroContext.currentPos()});
      case EBinop(OpMult, a, b):
        var meta = findMetaInBlock(a, b);
        retValBlock.push(meta);
      case EBinop(OpNotEq, a, b):
        var metaB = findMetaInBlock(b, rhs);
        var metaA = findMetaInBlock(a, rhs);

        retValBlock.push({expr: EBinop(OpNotEq, metaA, metaB), pos: macroContext.currentPos()});
      case EBinop(OpOr, a, b):
        var metaB = findMetaInBlock(b, rhs);
        var metaA = findMetaInBlock(a, rhs);
        retValBlock.push({expr: EBinop(OpOr, metaA, metaB), pos: macroContext.currentPos()});
      case EBinop(OpShl, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpShr, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpSub, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpUShr, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpXor, a, b):
        throw "AnnaLang: Unimplemented case";
      case _:
        throw "AnnaLang: This shouldn't be possible";
    }
  }

  private function handleMeta(entry, lhs, rhs):Expr {
    var result = switch(lhs.expr) {
      case EBinop(_, lhs, rhs):
        extractMeta(entry, lhs, rhs);
      case EMeta(em, expr):
        var lhsStr = printer.printExpr(lhs);
        var sides = lhsStr.split('=');
        lhs = haxeToExpr(sides[0]);
        if(sides.length == 2) {
          rhs = haxeToExpr(sides[1]);
        }
        extractMeta(entry, lhs, rhs);
      case _:
        extractMeta(entry, lhs, rhs);
    }
    return result;
  }

  private function extractMeta(entry, exprL: Expr, exprR: Expr): Expr {
    var funString: String = entry.name;
    var fun = Reflect.field(lang.macros.Macros, '_' + funString);
    var result = fun(exprL, exprR);
    var blk = extractBlock(result);
    if(blk.length == 1) {
      return findMetaInBlock(blk[0], exprR);
    } else {
      return result;
    }
  }

  public function extractBlock(expr: Expr):Array<Expr> {
    return switch(expr.expr) {
      case EBlock(exprs):
        exprs;
      case _:
        [expr];
    }
  }

  public function findMeta(expr: Expr, callback: Expr->Expr):Expr {
    return {
      switch(expr.expr) {
        case EArrayDecl(values) | ECall({ expr: EField({ expr: EArrayDecl(values)}, _)}, _) | EBlock(values):
          var arrayValues: Array<Expr> = [];
          for(value in values) {
            switch(value.expr) {
              case EBinop(OpArrow, a, b):
                collectMetaExpr(a, arrayValues);
                collectMetaExpr(b, arrayValues);
              case EMeta(metaName, {expr: EBinop(OpArrow, a, b), pos: _}):
                a = {expr: EMeta(metaName, a), pos: macroContext.currentPos()};
                collectMetaExpr(a, arrayValues);
                collectMetaExpr(b, arrayValues);
              case _:
                collectMetaExpr(value, arrayValues);
            }
          }
          expr = {expr: EArrayDecl(arrayValues), pos: macroContext.currentPos()};
          expr = callback(expr);
          expr;
        case EObjectDecl(values):
          var arrayValues: Array<Expr> = [];
          var finalArray: Array<Expr> = [];
          for(value in values) {
            collectMetaExpr(value.expr, arrayValues);
            var arrayVal = arrayValues.pop();
            finalArray.push({expr: EArrayDecl([{expr: EConst(CString(value.field, SingleQuotes)), pos: macroContext.currentPos()}, arrayVal]), pos: macroContext.currentPos()});
          }
          expr = {expr: EArrayDecl(finalArray), pos: macroContext.currentPos()};
          expr = callback(expr);
          expr;
        case EConst(CIdent(_)):
          expr;
        case EConst(CString(_, _)):
          expr = callback(expr);
          expr;
        case ECheckType(e, t):
          expr;
        case e:
          MacroLogger.logExpr(expr, "Unsupported expr");
          MacroLogger.log(expr, "Unsupported expr");
          throw("AnnaLang: Unsupported expression for now.");
      }
    }
  }

  private inline function collectMetaExpr(value: Expr, arrayValues: Array<Expr>): Void {
    var meta = findMetaInBlock(value, null);
    arrayValues.push(meta);
  }

  public function getLineNumber(pos: Position):Int {
    var str = '${pos}'.split(':')[1];
    return Std.parseInt(str);
  }

  private function _tuple(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        Tuple.create($e{expr});
      }
    });
  }

  private function _map(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        MMap.create($e{expr});
      }
    });
  }

  public function _list(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        LList.create($e{expr});
      }
    });
  }

  public function _atom(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        Atom.create($e{expr});
      }
    });
  }

  public function _keyword(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        Keyword.create($e{expr});
      }
    });
  }

  public function __(e1: Expr, e2: Expr):Expr {
    return _atom(e1, e2);
  }

  #if macro
  public static function _assert(lhs: Expr, rhs: Expr):Expr {
    var context: String = '${lhs.pos}';
    context = StringTools.replace(context, Sys.getCwd(), '');
    return macro {
      anna_unit.Assert.areEqual($e{lhs}, $e{rhs}, $v{context});
    }
  }
  #else
  public function _assert(lhs: Expr, rhs: Expr):Expr {
    return macro {
    }
  }
  #end

  #if macro
  public static function _refute(lhs: Expr, rhs: Expr):Expr {
    var context: String = '${lhs.pos}';
    context = StringTools.replace(context, Sys.getCwd(), '');
    return macro {
      anna_unit.Assert.areNotEqual($e{lhs}, $e{rhs}, $v{context});
    }
  }
  #else
  public function _refute(lhs: Expr, rhs: Expr):Expr {
    return macro {
    }
  }
  #end

  public function getPosContext(pos: Position): String {
    var context: String = '${pos}';
    context = StringTools.replace(context, Sys.getCwd(), '');
    return context;
  }

  public static var cache: Map<String, Expr> = new Map<String, Expr>();

  public function haxeToExpr(str: String, debug: Bool = false): Expr {
    if(cache.exists(str)) {
      return cache.get(str);
    } else {
      var ast = annaLang.parser.parseString(str);
      var retVal = new hscript.Macro(macroContext.currentPos()).convert(ast);
      cache.set(str, retVal);
      return retVal;
    }
  }

  macro public static function ei(expr: Expr): Expr {
    var retVal = macro {
      lang.macros.EitherMacro.gen(cast($e{expr}, Array<Dynamic>));
    };

    return retVal;
  }

  macro public function getTuple(expr: Expr): Expr {
    return macro null;
//    return _tuple(expr, null);
  }

  macro public function getMap(expr: Expr): Expr {
    return macro null;
//    return _map(expr, null);
  }

  macro public function getList(expr: Expr): Expr {
    return macro null;
//    return _list(expr, null);
  }

  macro public function getAtom(expr: Expr): Expr {
    return macro null;
//    return _atom(expr, null);
  }

  macro public function getKeyword(expr:Expr):Expr {
    return macro null;
//    return _keyword(expr, null);
  }
}