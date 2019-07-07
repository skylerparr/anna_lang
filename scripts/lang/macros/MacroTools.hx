package lang.macros;
#if macro
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Type.ClassType;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.MetadataEntry;
#end
import haxe.macro.Expr;
import haxe.macro.Context;
class MacroTools {

  public static function name(): Void {

  }

  #if macro
  public static function createClass(className: String): TypeDefinition {
    return {
      kind: TDClass(null,[],false),
      meta: [],
      name: className,
      pack: [],
      params: [],
      pos: Context.currentPos(),
      fields: [],
      isExtern: false
    };
  }
  
  public static function addMetaToClass(cls: TypeDefinition, meta: MetadataEntry):TypeDefinition {
    cls.meta.push(meta);
    return cls;
  }

  public static function addFieldToClass(field: Field):Void {
    MacroContext.currentModule.fields.push(field);
  }

  public static function assignFunBody(field: Field, body: Expr):Field {
    switch(field.kind) {
      case FFun(f):
        f.expr = body;
      case _:
        throw new ParsingException("AnnaLang: Expected function");
    }
    return field;
  }
  
  public static function buildMeta(name: String, params: Null<Array<Expr>>):MetadataEntry {
    return {
      name: name,
      params: params,
      pos: Context.currentPos()
    }
  }

  public static function buildConst(value: Constant):Expr {
    return {
      expr: EConst(value),
      pos: Context.currentPos()
    };
  }
  
  public static function buildExprField(ident: Expr, field: String):Expr {
    return {
      expr: EField(ident, field),
      pos: Context.currentPos()
    };
  }
  
  public static function buildCall(field: Expr, params: Array<Expr>):Expr {
    return {
      expr: ECall(field, params),
      pos: Context.currentPos()
    };
  }

  public static function buildReturn(ident: Expr):Expr {
    return {
      expr: EReturn(ident),
      pos: Context.currentPos()
    }
  }

  public static function buildType(typeString: String):ComplexType {
    var expr = Macros.haxeToExpr('var x: ${typeString};');
    var type = switch(expr.expr) {
      case EVars([_var]):
        _var.type;
      case _:
        throw new ParsingException('AnnaLang: not possible');
    }
    return type;
  }

  public static function buildBlock(blk: Array<Expr>): Expr {
    return {
      expr: EBlock(blk),
      pos: Context.currentPos(),
    }
  }

  public static function buildPublicFunction(name: String, params: Array<Expr>, returnType: ComplexType): Field {
    var varName: String = '_${name}';

    return {
      access: [APublic, AStatic],
      kind: FFun({
        args: [],
        expr: null,
        ret: returnType
      }),
      name: name,
      pos: Context.currentPos()
    }
  }

  public static function buildPublicVar(name: String, initBody: Array<Expr>): Field {
    var funName: String = '_${name}';

    var varBody: Array<Expr> = [{
      expr: EBinop(OpAssign,{
        expr: EConst(CIdent(funName)),
        pos: Context.currentPos()
      },{
        expr: EArrayDecl([]),
        pos: Context.currentPos()
      }),
      pos: Context.currentPos()
    }];

    for(expr in initBody) {
      varBody.push(expr);
    }
    varBody.push(buildConst(CIdent(funName)));

    return {
      kind: FVar(TPath({
        name: 'Array',
        pack: [],
        params: [
          TPType(TPath({
            name: 'Operation',
            pack: ['vm'],
            params: []
          }))
        ]
      }),
      buildBlock(varBody)),
      name: funName,
      pos: Context.currentPos(),
      access: [AStatic,APublic]
    }
  }

  public static function getCallFunName(expr: Expr):String {
    return switch(expr.expr) {
      case ECall({expr: EConst(CIdent(name))}, _):
        name;
      case ECall(expr, _):
        var fun = extractFullFunCall(expr);
        fun.join('.');
      case EField(expr, field):
        var fun = extractFullFunCall(expr);
        '${fun.join('.')}.${field}';
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected function call definition");
    }
  }

  public static function getAliasName(expr: Expr):String {
    var fullFunCall: Array<String> = extractFullFunCall(expr);
    return fullFunCall[fullFunCall.length - 1];
  }

  public static function getFunctionName(expr: Expr, acc: Array<String> = null):String {
    if(acc == null) {
      acc = [];
    }
    return switch(expr.expr) {
      case ECall({expr: EField(fieldExpr, field)}, _):
        field;
      case _:
        throw new ParsingException("AnnaLang: Expected call and field definition");
    }
  }

  public static function getFunBody(expr: Expr):Array<Expr> {
    switch(expr.expr) {
      case ECall({expr: EConst(CIdent(name))}, body):
        return body;
      case ECall({expr: EField(_, _)}, body):
        return body;
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected function body definition");
    }

  }

  public static function getModuleName(expr: Expr):String {
    var fullFunCall: Array<String> = extractFullFunCall(expr);
    return fullFunCall.join('.');
  }

  public static function extractFullFunCall(expr: Expr, acc: Array<String> = null):Array<String> {
    if(acc == null) {
      acc = [];
    }
    return switch(expr.expr) {
      case ECall({expr: EField(fieldExpr, _)}, _):
        var n = extractFullFunCall(fieldExpr, acc);
        acc;
      case EField(fieldExpr, fieldName):
        var n = extractFullFunCall(fieldExpr, acc);
        acc.push(fieldName);
        acc;
      case EConst(CIdent(name)):
        acc.push(name);
        acc;
      case _:
        throw new ParsingException("AnnaLang: Expected package definition");
    }
  }

  #end

}