package lang.macros;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
#if macro
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Type.ClassType;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.MetadataEntry;
#end
class MacroTools {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

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

  public static function addFieldToClass(cls: TypeDefinition, field: Field):Void {
    cls.fields.push(field);
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
    var expr = lang.macros.Macros.haxeToExpr('var x: ${typeString};');
    var type = switch(expr.expr) {
      case EVars([_var]):
        _var.type;
      case _:
        throw new ParsingException('AnnaLang: not possible');
    }
    return type;
  }

  public static function buildBlock(blk: Array<Expr>): Expr {
    if(blk == null || blk.length == 0) {
      return null;
    } else {
      return {
        expr: EBlock(blk),
        pos: Context.currentPos(),
      }
    }
  }

  public static function buildPublicFunction(name: String, params: Array<FunctionArg>, returnType: ComplexType): Field {
    var varName: String = '_${name}';

    return {
      access: [APublic],
      kind: FFun({
        args: params,
        expr: null,
        ret: returnType
      }),
      name: name,
      pos: Context.currentPos()
    }
  }

  public static function buildPrivateFunction(name: String, params: Array<FunctionArg>, returnType: ComplexType): Field {
    var varName: String = '_${name}';

    return {
      access: [APrivate, AInline],
      kind: FFun({
        args: params,
        expr: null,
        ret: returnType
      }),
      name: name,
      pos: Context.currentPos()
    }
  }

  public static function buildPublicVar(name: String, varType: ComplexType, initBody: Array<Expr>): Field {
    var funName: String = name;
    var varBody: Array<Expr> = [];
    for(expr in initBody) {
      varBody.push(expr);
    }

    return {
      kind: FVar(varType, buildBlock(varBody)),
      name: funName,
      pos: Context.currentPos(),
      access: [APublic]
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

  public static function getIdent(expr: Expr):String {
    return switch(expr.expr) {
      case EConst(CIdent(name)):
        return name;
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException('AnnaLang: Expected variable identifier, got ${printer.printExpr(expr)}');
    }
  }

  public static function getValue(expr: Expr):Dynamic {
    return switch(expr.expr) {
      case EConst(CString(value)):
        value;
      case EConst(CInt(value)) | EConst(CFloat(value)):
        value;
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Unexpected value.");
    }
  }

  public static function getTypeAndValue(expr: Expr):Dynamic {
    return switch(expr.expr) {
      case EConst(CIdent(varName)):
        {type: "Dynamic", value: '@tuple [@atom "var", "${varName}"]'};
      case EConst(CString(value)):
        {type: "String", value: '@tuple [@atom "const", "${value}"]'};
      case EConst(CInt(value)):
        {type: "Number", value: '@tuple [@atom "const", ${value}]'};
      case EConst(CFloat(value)):
        {type: "Number", value: '@tuple [@atom "const", ${value}]'};
      case EMeta({name: "atom" | "_"}, {expr: EConst(CString(value))}):
        {type: "Atom", value: '@tuple [@atom "const", @atom "${value}"]'};
      case EMeta({name: "tuple"}, {expr: EArrayDecl(values)}):
        {type: "Tuple", value: '@tuple [@atom "const", @tuple ${values}]'};
      case EMeta({name: "list"}, {expr: EArrayDecl(values)}):
        {type: "LList", value: '@tuple [@atom "const", @tuple ${values}]'};
      case EBlock(args):
        var listValues: Array<String> = [];
        for(arg in args) {
          listValues.push(printer.printExpr(arg));
        }
        {type: "LList", value: '@tuple [@atom "const", @list[${listValues.join(",")}]]'};
      case EArrayDecl(args):
        var listValues: Array<String> = [];
        var isList: Bool = false;
        for(arg in args) {
          switch(arg.expr) {
            case EBinop(OpArrow, key, value):
              isList = false;
              listValues.push('${printer.printExpr(key)} => ${printer.printExpr(value)}');
            case _:
              isList = true;
              listValues.push(printer.printExpr(arg));
          }
        }
        if(isList) {
          {type: "Tuple", value: '@tuple [@atom "const", @tuple[${listValues.join(",")}]]'};
        } else {
          {type: "MMap", value: '@tuple [@atom "const", @map[${listValues.join(",")}]]'};
        }
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected type and value or variable name");
    }
  }

  public static function getArgTypesAndReturnTypes(expr: Expr):Dynamic {
    return switch(expr.expr) {
      case ECall(f, params):
        var retVal: Dynamic = {argTypes: [], returnTypes: [], patterns: []};
        for(param in params) {
          switch(param.expr) {
            case EBlock(_):
              break;
            case EObjectDecl(values):
              for(value in values) {
                var expr: Expr = cast value.expr;
                var nameAndPattern: Dynamic = switch(expr.expr) {
                  case EConst(CIdent(name)):
                    {name: name, pattern: name}
                  case EConst(CInt(pattern)) | EConst(CString(pattern)) | EConst(CFloat(pattern)):
                    var name = util.StringUtil.random();
                    {name: name, pattern: pattern};
                  case EArrayDecl(values):
                    var name = util.StringUtil.random();
                    var items: Array<String> = [];
                    var type: String = 'tuple';
                    for(value in values) {
                      switch(value.expr) {
                        case EBinop(OpArrow, key, value):
                          type = 'map';
                          items.push('${printer.printExpr(key)} => ${printer.printExpr(value)}');
                        case _:
                          items.push(printer.printExpr(value));
                      }
                    }
                    var haxeStr: String = '@${type}[${items.join(',')}]';
                    {name: name, pattern: haxeStr};
                  case EBlock(values):
                    var name = util.StringUtil.random();
                    var items: Array<String> = [];
                    for(value in values) {
                      items.push(printer.printExpr(value));
                    }
                    var haxeStr: String = '@list[${items.join(',')}]';
                    {name: name, pattern: haxeStr};
                  case e:
                    MacroLogger.log(e, 'e');
                    throw new ParsingException("AnnaLang: expected variable or pattern");
                }
                retVal.argTypes.push({type: value.field, name: nameAndPattern.name, pattern: nameAndPattern.pattern});
              }
            case EArrayDecl(returnTypes):
              MacroContext.returnTypes = [];
              for(returnType in returnTypes) {
                retVal.returnTypes.push(getIdent(returnType));
              }
            case e:
              MacroLogger.log(e, 'e');
              throw new ParsingException("AnnaLang: Unexpected argument type");
          }
        }
        retVal;
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected value types");
    }
  }

  public static function resolveType(expr: Expr):String {
    var type: Type = Context.typeof(expr);
    return switch(type) {
      case TInst(t, other):
        switch(t.get().interfaces) {
          case [{t: type}] if(!t.get().isInterface):
            type.toString();
          case _:
            t.toString();
        }
      case TAbstract(t, _):
        t.toString();
      case TDynamic(_):
        "Dynamic";
      case TType(t, _):
        t.toString();
      case t:
        MacroLogger.log(t, 't');
        throw "AnnaLang: Unhandled return type";
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
    return switch(expr.expr) {
      case ECall({expr: EConst(CIdent(name))}, body):
        body;
      case ECall({expr: EField(e, field)}, body):
        body;
      case EConst(_):
        [expr];
      case EMeta(_, _) | EArrayDecl(_) | EBlock(_):
        [expr];
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected function body definition");
    }

  }

  public static function getModuleName(expr: Expr):String {
    var fullFunCall: Array<String> = extractFullFunCall(expr);
    return fullFunCall.join('.');
  }

  public static function getLineNumber(expr: Expr):Int {
    var lineStr: String = '${expr.pos}';
    var lineNo: Int = Std.parseInt(lineStr.split(':')[1]);
    return lineNo;
  }

  public static function getType(tpath: ComplexType):String {
    return switch(tpath) {
      case TPath({name: name}):
        name;
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected type");
    }
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
      case EConst(CString(value)) | EConst(CInt(value)) | EConst(CFloat(value)):
        acc.push(value);
        acc;
      case EMeta(_, _) | EArrayDecl(_) | EBlock(_):
        acc.push(printer.printExpr(expr));
        acc;
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected package definition");
    }
  }

  #end

}