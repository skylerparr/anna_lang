package;

import haxe.macro.Context;
import lang.macros.MacroLogger;
import haxe.macro.Expr;

//  =>
// #pos\(.*?\)
class Macros {

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
            var metaInBlock = findMetaInBlock(blk);
            field.kind = FVar(fvar, metaInBlock);
            field;
          case EMeta(entry, expr):
            var metaBlock = extractMeta(entry, expr);
            field.kind = FVar(fvar, metaBlock);
            field;
          case _:
            field;
        }
      case FFun(ffun):
        var exprs = extractBlock(ffun.expr);
        var retValExprs: Array<Expr> = [];
        for(expr in exprs) {
          var e = findMetaInBlock([expr]);
          var blk = extractBlock(e);
          retValExprs.push(blk[0]);
        }
        ffun.expr = {expr: EBlock(retValExprs), pos: Context.currentPos()};
        field.kind = FFun(ffun);
        field;
      case FProp(get, set, t, e):
        field;
    }
  }

  private static function findMetaInBlock(exprs: Array<Expr>):Expr {
    var retValBlock: Array<Expr> = [];
    for(expr in exprs) {
      switch(expr.expr) {
        case ECall(ecall, params):
          var valueBlocks: Array<Expr> = [];
          for(param in params) {
            var meta = findMetaInBlock([param]);
            var metaBlock: Array<Expr> = extractBlock(meta);
            valueBlocks.push(metaBlock[0]);
          }
          retValBlock.push({expr: ECall(ecall, valueBlocks), pos: Context.currentPos()});
        case EMeta(entry, expr):
          return extractMeta(entry, expr);
        case ENew(enew, params):
          var meta = findMetaInBlock(params);
          var metaBlock: Array<Expr> = extractBlock(meta);
          retValBlock.push({expr: ENew(enew, metaBlock), pos: Context.currentPos()});
        case EArrayDecl(values):
          var valueBlocks: Array<Expr> = [];
          for(value in values) {
            var meta = findMetaInBlock([value]);
            var metaBlock: Array<Expr> = extractBlock(meta);
            valueBlocks.push(metaBlock[0]);
          }
          retValBlock.push({expr: EArrayDecl(valueBlocks), pos: Context.currentPos()});
        case EField(fieldExpr, field):
          retValBlock.push(expr);
        case EVars(vars):
          var retVars: Array<Var> = [];
          for(v in vars) {
            var meta = findMetaInBlock([v.expr]);
            var blk = extractBlock(meta);
            v.expr = blk[0];
            retVars.push(v);
          }
          retValBlock.push(expr);
        case EBinop(OpArrow, a, b):
          var meta = findMetaInBlock([a]);
          var blk = extractBlock(meta);
          retValBlock.push(blk[0]);

          meta = findMetaInBlock([b]);
          blk = extractBlock(meta);
          retValBlock.push(blk[0]);
        case EBinop(OpAssign, a, b):
          var meta = findMetaInBlock([b]);
          var blk = extractBlock(meta);
          retValBlock.push({expr: EBinop(OpAssign, a, blk[0]), pos: Context.currentPos()});
        case _:
          retValBlock.push(expr);
      }
    }
    var block: Expr = {expr: EBlock(retValBlock), pos: Context.currentPos()};
    return block;
  }

  private static function extractMeta(entry, expr): Expr {
    var funString: String = entry.name;
    var fun = Reflect.field(Macros, funString);
    return fun(expr);
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
          var blk = extractBlock(expr)[0];
          blk;
        case EConst(CString(e)):
          macro {
            lang.AtomSupport.atom($expr);
          };
        case _:
          throw("AnnaLang: Unsupported expression for now.");
      }
    }
  }

  private static inline function collectMetaExpr(value: Expr, arrayValues: Array<Expr>): Void {
    var meta = findMetaInBlock([value]);
    var metaBlock = extractBlock(meta);
    if(metaBlock[0] != null) {
      arrayValues.push(metaBlock[0]);
    }
  }

  private static function tuple(expr: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        Tuple.create(EitherMacro.gen(cast($e{expr}, Array<Dynamic>)));
      }
    });
  }

  private static function map(expr: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        MMap.create(EitherMacro.genMap(cast($e{expr}, Array<Dynamic>)));
      }
    });
  }

  public static function list(expr: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        LList.create(EitherMacro.gen(cast($e{expr}, Array<Dynamic>)));
      }
    });
  }

  public static function atom(expr: Expr):Expr {
    return findMeta(expr, function(expr: Expr): Expr {
      return macro {
        Atom.create($e{expr});
      }
    });
  }

  #end

  macro public static function ei(expr: Expr): Expr {
    var retVal = macro {
      EitherMacro.gen(cast($e{expr}, Array<Dynamic>));
    };

    return retVal;
  }

  macro public static function getTuple(expr: Expr): Expr {
    return tuple(expr);
  }

  macro public static function getMap(expr: Expr): Expr {
    return map(expr);
  }

  macro public static function getList(expr: Expr): Expr {
    return list(expr);
  }

  macro public static function getAtom(expr: Expr): Expr {
    return atom(expr);
  }
}