package;

import hscript.Parser;
import haxe.macro.Printer;
import haxe.macro.Context;
import lang.macros.MacroLogger;
import haxe.macro.Expr;

//  =>
// #pos\(.*?\)
class Macros {

  private static var parser: Parser = {
    parser = new Parser();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  macro public static function build(args: Expr = null): Array<Field> {
    MacroLogger.log("=====================");
    MacroLogger.log('Macros: ${Context.getLocalClass()}');
    var fields: Array<Field> = Context.getBuildFields();
    var retFields: Array<Field> = [];
    for(field in fields) {
      var newField: Field = updateField(field);
      retFields.push(newField);
    }
    MacroLogger.log("---------------------");
    MacroLogger.printFields(retFields);
    MacroLogger.log("_____________________");
    return retFields;
  }

  #if macro
  private static function updateField(field: Field): Field {
    return switch(field.kind) {
      case FVar(fvar, e):
        switch(e.expr) {
          case EBlock(blk):
            var metaInBlock: Array<Expr> = [];
            for(expr in blk) {
              var e = findMetaInBlock(expr, null);
              metaInBlock.push(e);
            }
            var eblock = EBlock(metaInBlock);
            field.kind = FVar(fvar, {expr: eblock, pos: Context.currentPos()});
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
        ffun.expr = {expr: EBlock(retValExprs), pos: Context.currentPos()};
        field.kind = FFun(ffun);
        field;
      case FProp(get, set, t, e):
        field;
    }
  }

  private static function findMetaInBlock(expr: Expr, rhs: Expr):Expr {
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
        retValBlock.push({expr: ECall(ecall, valueBlocks), pos: Context.currentPos()});
      case EMeta(entry, expr):
        return handleMeta(entry, expr, rhs);
      case ENew(enew, params):
        var valueBlocks: Array<Expr> = [];
        for(param in params) {
          var meta = findMetaInBlock(param, rhs);
          valueBlocks.push(meta);
        }
        retValBlock.push({expr: ENew(enew, valueBlocks), pos: Context.currentPos()});
      case EArrayDecl(values):
        var valueBlocks: Array<Expr> = [];
        for(value in values) {
          var meta = findMetaInBlock(value, rhs);
          valueBlocks.push(meta);
        }
        retValBlock.push({expr: EArrayDecl(valueBlocks), pos: Context.currentPos()});
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
        retValBlock.push({expr: EBlock(updatedMeta), pos: Context.currentPos()});
      case EIf(econd, eif, eelse):
        var econdMeta = findMetaInBlock(econd, null);
        var eifMeta = findMetaInBlock(eif, null);
        var eelseMeta = findMetaInBlock(eelse, null);
        retValBlock.push({expr: EIf(econdMeta, eifMeta, eelseMeta), pos: Context.currentPos()});
      case EArray(e1, e2):
        throw "AnnaLang: Unimplemented case";
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
      case EDisplay(e, isCall):
        throw "AnnaLang: Unimplemented case";
      case EDisplayNew(t):
        throw "AnnaLang: Unimplemented case";
      case EFor(it, expr):
        throw "AnnaLang: Unimplemented case";
      case EIn(e1, e2):
        throw "AnnaLang: Unimplemented case";
      case EObjectDecl(fields):
        retValBlock.push(expr);
      case EParenthesis(e):
        throw "AnnaLang: Unimplemented case";
      case EReturn(e):
        retValBlock.push(expr);
      case ESwitch(e, cases, edef):
        retValBlock.push(expr);
      case ETernary(econd, eif, eelse):
        throw "AnnaLang: Unimplemented case";
      case EThrow(e):
        retValBlock.push(expr);
      case ETry(e, catches):
        throw "AnnaLang: Unimplemented case";
      case EUnop(op, postFix, e):
        throw "AnnaLang: Unimplemented case";
      case EUntyped(e):
         throw "AnnaLang: Unimplemented case";
      case EWhile(econd, e, normalWhile):
        throw "AnnaLang: Unimplemented case";
    }
    if(retValBlock.length == 1) {
      return retValBlock[0];
    } else {
      var block: Expr = {expr: EBlock(retValBlock), pos: Context.currentPos()};
      return block;
    }
  }

  private static function handleBinop(expr: Expr, rhs: Expr, retValBlock: Array<Expr>):Void {
    switch(expr.expr) {
      case EBinop(OpArrow, a, b):
        var meta = findMetaInBlock(a, rhs);
        retValBlock.push(meta);

        meta = findMetaInBlock(b, rhs);
        retValBlock.push(meta);
      case EBinop(OpAssign, a, b):
        var metaB = findMetaInBlock(b, rhs);
        var metaA = findMetaInBlock(a, rhs);

        retValBlock.push({expr: EBinop(OpAssign, metaA, metaB), pos: Context.currentPos()});
      case EBinop(OpEq, a, b):
        var meta = findMetaInBlock(a, b);
        retValBlock.push(meta);
      case EBinop(OpAdd, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpAnd, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpBoolAnd, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpBoolOr, a, b):
        throw "AnnaLang: Unimplemented case";
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
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpMult, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpNotEq, a, b):
        throw "AnnaLang: Unimplemented case";
      case EBinop(OpOr, a, b):
        throw "AnnaLang: Unimplemented case";
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

  private static function handleMeta(entry, lhs, rhs):Expr {
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

  private static function extractMeta(entry, exprL: Expr, exprR: Expr): Expr {
    var funString: String = entry.name;
    var fun = Reflect.field(Macros, funString);
    var result = fun(exprL, exprR);
    var blk = extractBlock(result);
    if(blk.length == 1) {
      return findMetaInBlock(blk[0], exprR);
    } else {
      return result;
    }
  }

  public static function extractBlock(expr: Expr):Array<Expr> {
    return switch(expr.expr) {
      case EBlock(exprs):
        exprs;
      case _:
        [expr];
    }
  }

  public static function findMeta(expr: Expr, callback: Expr->Expr):Expr {
    return {
      switch(expr.expr) {
        case EArrayDecl(values):
          var arrayValues: Array<Expr> = [];
          for(value in values) {
            switch(value.expr) {
              case EBinop(OpArrow, a, b):
                collectMetaExpr(a, arrayValues);
                collectMetaExpr(b, arrayValues);
              case _:
                collectMetaExpr(value, arrayValues);
            }
          }
          expr = {expr: EArrayDecl(arrayValues), pos: Context.currentPos()};
          expr = callback(expr);
          expr;
        case EConst(CIdent(_)):
          expr;
        case EConst(CString(_)):
          expr = callback(expr);
          expr;
        case ECheckType(e, t):
          expr;
        case e:
          MacroLogger.log(e, "Unsupported");
          throw("AnnaLang: Unsupported expression for now.");
      }
    }
  }

  private static inline function collectMetaExpr(value: Expr, arrayValues: Array<Expr>): Void {
    var meta = findMetaInBlock(value, null);
    arrayValues.push(meta);
  }

  public static function getLineNumber(pos: Position):Int {
    var str = '${pos}'.split(':')[1];
    return Std.parseInt(str);
  }

  private static function tuple(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        Tuple.create(EitherMacro.gen(cast($e{expr}, Array<Dynamic>)));
      }
    });
  }

  private static function map(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        MMap.create(EitherMacro.genMap(cast($e{expr}, Array<Dynamic>)));
      }
    });
  }

  public static function list(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        LList.create(EitherMacro.gen(cast($e{expr}, Array<Dynamic>)));
      }
    });
  }

  public static function atom(expr: Expr, _: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        Atom.create($e{expr});
      }
    });
  }

  public static function assert(lhs: Expr, rhs: Expr):Expr {
    var context: String = '${lhs.pos}';
    context = StringTools.replace(context, Sys.getCwd(), '');
    return macro {
      anna_unit.Assert.areEqual($e{lhs}, $e{rhs}, $v{context});
    }
  }

  public static function refute(lhs: Expr, rhs: Expr):Expr {
    var context: String = '${lhs.pos}';
    context = StringTools.replace(context, Sys.getCwd(), '');
    return macro {
      anna_unit.Assert.areNotEqual($e{lhs}, $e{rhs}, $v{context});
    }
  }

  public static function _if(lhs: Expr, rhs: Expr):Expr {
    return macro {

    };
  }

  public static function match(lhs: Expr, rhs: Expr):Expr {
    var p: Printer = new Printer();
    var lhsStr: String = p.printExpr(lhs);
    var rhsStr: String = p.printExpr(rhs);
    var context: String = '${lhs.pos}';
    context = StringTools.replace(context, Sys.getCwd(), '');

    var haxeStr: String = 'Macros.valuesMatch(${lhsStr}, ${rhsStr})';

    return haxeToExpr(haxeStr);
  }

  public static function haxeToExpr(str: String): Expr {
    var ast = parser.parseString(str);
    return new hscript.Macro(Context.currentPos()).convert(ast);
  }
  #end

  macro public static function ei(expr: Expr): Expr {
    var retVal = macro {
      EitherMacro.gen(cast($e{expr}, Array<Dynamic>));
    };

    return retVal;
  }

  macro public static function getTuple(expr: Expr): Expr {
    return tuple(expr, null);
  }

  macro public static function getMap(expr: Expr): Expr {
    return map(expr, null);
  }

  macro public static function getList(expr: Expr): Expr {
    return list(expr, null);
  }

  macro public static function getAtom(expr: Expr): Expr {
    return atom(expr, null);
  }

  macro public static function valuesMatch(lhs: Expr, rhs: Expr): Expr {
    MacroLogger.log(lhs, 'lhs');
    MacroLogger.log(rhs, 'rhs');
    return switch(lhs.expr) {
      case EConst(CString(val)) | EConst(CInt(val)) | EConst(CFloat(val)):
        macro {
          if(Anna.toAnnaString($e{lhs}) == Anna.toAnnaString($e{rhs})) {

          } else {
            throw new lang.UnableToMatchException('Unable to match expression ${Context.currentPos()}: ${printer.printExpr(lhs)} = ${printer.printExpr(rhs)}');
          }
        }
      case ECall({expr: EField({expr: EConst(CIdent('Atom'))}, 'create')}, _):
        macro {
          if(Anna.toAnnaString($e{lhs}) == Anna.toAnnaString($e{rhs})) {

          } else {
            throw new lang.UnableToMatchException('Unable to match expression ${Context.currentPos()}: ${printer.printExpr(lhs)} = ${printer.printExpr(rhs)}');
          }
        }
      case EConst(CIdent(variable)):
        var strExpr = 'var ${printer.printExpr(lhs)} = ${printer.printExpr(rhs)};';
        var e = haxeToExpr(strExpr);
        e;
      case e:
        MacroLogger.log(e, "values match e");
        throw "unsupported";
    }
  }
}