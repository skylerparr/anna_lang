package;

import lang.macros.MacroLogger;
import haxe.macro.Context;
import lang.macros.MacroLogger;
import haxe.macro.Expr;

//  =>
// #pos\(.*?\)
class Macros {

  macro public static function build(): Array<Field> {
    var fields: Array<Field> = Context.getBuildFields();
    var retFields: Array<Field> = [];
    for(field in fields) {
      var newField: Field = updateField(field);
      retFields.push(newField);
    }
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
          case _:
            field;
        }
      case FFun(ffun):
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
          var meta = findMetaInBlock(params);
          var metaBlock: Array<Expr> = extractBlock(meta);
          if(meta != null) {
            var expr = { expr: ECall(ecall, metaBlock), pos: Context.currentPos() };
            retValBlock.push(expr);
          } else {
            retValBlock.push(expr);
          }
        case EMeta(entry, expr):
          var funString: String = entry.name;
          var fun = Reflect.field(Macros, funString);
          return fun(expr);
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
        case _:
          retValBlock.push(expr);
      }
    }
    var block: Expr = {expr: EBlock(retValBlock), pos: Context.currentPos()};
    return block;
  }

  private static function tuple(expr: Expr):Expr {
    return macro {
      Tuple.create(EitherMacro.gen(cast($e{expr}, Array<Dynamic>)));
    }
  }

  private static function extractBlock(expr: Expr):Array<Expr> {
    return switch(expr.expr) {
      case EBlock(exprs):
        exprs;
      case _:
        [expr];
    }
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
}