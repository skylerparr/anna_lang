package lang;

import lang.macros.MacroLogger;
import haxe.macro.Expr;

interface CustomType {
  function toAnnaString(): String;
  function toHaxeString(): String;
  function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String;
}

class CustomTypes {
  public static function set(obj: CustomType, field: String, value: Dynamic): CustomType {
    Reflect.setField(obj, field, value);
    return obj;
  }

  macro public static function createList(typeExpr: Expr, itemsExpr: Expr): Expr {
    var type = switch(typeExpr.expr) {
      case EConst(CString(t)):
        var classAndPackage = getClassAndPackage(t);
        TPath({ pack : classAndPackage.packageName, name : classAndPackage.className, params : [], sub : null });
      case t:
        throw new UnexpectedArgumentException('Expected array, got ${t}');
    }

    return macro {
      {
        var retVal: AnnaList<$type> = new AnnaList<$type>();
        util.CollectionUtil.fillList(retVal, $e{itemsExpr});
        retVal;
      }
    }
  }

  macro public static function createMap(keyTypeExpr: Expr, valueTypeExpr: Expr, itemsExpr: Expr): Expr {
    var keyType = switch(keyTypeExpr.expr) {
      case EConst(CString(t)):
        var classAndPackage = getClassAndPackage(t);
        TPath({ pack : classAndPackage.packageName, name : classAndPackage.className, params : [], sub : null });
      case t:
        throw new UnexpectedArgumentException('Expected array, got ${t}');
    }
    var valueType = switch(valueTypeExpr.expr) {
      case EConst(CString(t)):
        var classAndPackage = getClassAndPackage(t);
        TPath({ pack : classAndPackage.packageName, name : classAndPackage.className, params : [], sub : null });
      case t:
        throw new UnexpectedArgumentException('Expected array, got ${t}');
    }

    return macro {
      {
        var retVal: AnnaMap<$keyType, $valueType> = new AnnaMap<$keyType, $valueType>();
        util.CollectionUtil.fillMap(retVal, $e{itemsExpr});
        retVal;
      }
    }
  }

  public static function getClassAndPackage(fullClass: String): Dynamic {
    var frags: Array<String> = fullClass.split('.');
    var className: String = frags.pop();
    return {className: className, packageName: frags};
  }
}