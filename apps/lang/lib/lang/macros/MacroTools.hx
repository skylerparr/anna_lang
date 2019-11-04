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

  macro public static function line(): Expr {
    var lineStr = Context.currentPos() + '';
    var lineNo: Int = Std.parseInt(lineStr.split(':')[1]);
    return Macros.haxeToExpr('${lineNo}');
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
    // TODO: dry a lot of this up!
    return switch(expr.expr) {
      case EConst(CIdent(varName)):
        var const: Expr = MacroContext.currentModuleDef.constants.get(varName);
        if(const == null) {
          {type: "Variable", value: '@tuple [@atom "var", "${varName}"]', rawValue: varName};
        } else {
          getTypeAndValue(const);
        }
      case EConst(CString(value)):
        {type: "String", value: '@tuple [@atom "const", "${value}"]', rawValue: '"${value}"'};
      case EConst(CInt(value)):
        {type: "Number", value: '@tuple [@atom "const", ${value}]', rawValue: value};
      case EConst(CFloat(value)):
        {type: "Number", value: '@tuple [@atom "const", ${value}]', rawValue: value};
      case EMeta({name: "atom" | "_"}, {expr: EConst(CString(value))}):
        var strValue: String = '@atom "${value}"';
        {type: "Atom", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
      case EMeta({name: "tuple"}, {expr: EArrayDecl(values)}):
        var finalValues: Array<String> = [];
        for(value in values) {
          var typeAndValue: Dynamic = getTypeAndValue(value);
          finalValues.push(typeAndValue.rawValue);
        }
        var strValue: String = '@tuple ${finalValues.join(', ')}';
        {type: "Tuple", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
      case EMeta({name: "list"}, {expr: EArrayDecl(args)}):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue: Dynamic = getTypeAndValue(arg);
          listValues.push(typeAndValue.rawValue);
        }
        var strValue: String = '@list[${listValues.join(",")}]';
        {type: "LList", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
      case EMeta({name: "map"}, {expr: EArrayDecl(args)}):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue: Dynamic = extractMapValues(arg);
          listValues.push(typeAndValue.rawValue);
        }
        var strValue: String = '@map[${listValues.join(",")}]';
        {type: "MMap", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
      case EBlock(args):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue: Dynamic = getTypeAndValue(arg);
          listValues.push(typeAndValue.rawValue);
        }
        var strValue: String = '@list[${listValues.join(",")}]';
        {type: "LList", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
      case EArrayDecl(args):
        var listValues: Array<String> = [];
        var isList: Bool = false;
        for(arg in args) {
          switch(arg.expr) {
            case EBinop(OpArrow, key, value):
              var keyType = getTypeAndValue(key);
              var valueType = getTypeAndValue(value);
              listValues.push('${keyType.rawValue} => ${valueType.rawValue}');
            case _:
              try {
                var typeAndValue = extractMapValues(arg);
                listValues.push(typeAndValue.rawValue);
              } catch(e: Dynamic) {
                isList = true;
                var typeAndValue = getTypeAndValue(arg);
                listValues.push(typeAndValue.rawValue);
              }
          }
        }
        if(isList) {
          var strValue: String = '@tuple[${listValues.join(",")}]';
          {type: "Tuple", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
        } else {
          var strValue: String = '@map[${listValues.join(",")}]';
          {type: "MMap", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
        }
      case EBinop(OpArrow, const, {expr: EBinop(OpAssign, pattern, rhs)}):
        var strConst: String = printer.printExpr(pattern);
        {type: "String", value: '@tuple [@atom "var", "${strConst}"]', rawValue: printer.printExpr(expr)};
      case EBinop(OpArrow, lhs, rhs):
        var lhsType = getTypeAndValue(lhs);
        var rhsType = getTypeAndValue(rhs);
        var rawValue: String = '@map [${lhsType.rawValue} => ${rhsType.rawValue}]';
        {type: "MMap", value: rawValue, rawValue: rawValue};
      case EMeta({name: '__stringMatch'}, expr):
        var value: String = printer.printExpr(expr);
        {type: "String", value: value, rawValue: value};
      case EObjectDecl(items):
        var keyValues: Array<String> = [];
        for(item in items) {
          var typeAndValue = getTypeAndValue(item.expr);
          var rawValue = switch(item.expr.expr) {
            case EConst(CIdent(_)):
              typeAndValue.value;
            case _:
              typeAndValue.rawValue;
          }
          keyValues.push('${item.field}: ${rawValue}');
        }
        var strValue: String = '{${keyValues.join(', ')}}';
        {type: "CustomType", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
      case ECast(expr, TPath({ name: type })):
        var typeAndValue = getTypeAndValue(expr);
        {type: AnnaLang.getAlias(type), value: typeAndValue.rawValue, rawValue: typeAndValue.rawValue};
      case e:
        MacroLogger.log(expr, 'expr');
        MacroLogger.logExpr(expr, 'expr');
        throw new ParsingException("AnnaLang: Expected type and value or variable name");
    }
  }

  private static function extractMapValues(arg: Expr):Dynamic {
    var listValues: Array<String> = [];
    switch(arg.expr) {
      case EBinop(OpArrow, key, value):
        var keyType = getTypeAndValue(key);
        var valueType = getTypeAndValue(value);
        listValues.push('${keyType.rawValue} => ${valueType.rawValue}');
      case EMeta({name: "atom"}, e) | EMeta({name: "tuple"}, e) | EMeta({name: "list"}, e):
        // special case for when map has atom, tuple, or list keys
        var typeAndValue: Dynamic = getTypeAndValue(e);
        listValues.push(typeAndValue.rawValue);
      case EMeta({name: "map"}, {expr: EBinop(OpArrow, key, value)}):
        // special case for when map has map keys
        var keyType = getTypeAndValue(key);
        var valueType = getTypeAndValue(value);
        listValues.push('${keyType.rawValue} => ${valueType.rawValue}');
      case _:
        throw 'AnnaLang: Unexpected key ${printer.printExpr(arg)}';
    }
    var strValue: String = '@map[${listValues.join(",")}]';
    return {type: "MMap", value: '@tuple [@atom "const", ${strValue}]', rawValue: strValue};
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
                  case EObjectDecl(values):
                    var name = util.StringUtil.random();
                    {name: name, pattern: '@list[]'};
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
                  case EBinop(OpArrow, {expr: EConst(CString(name))}, {expr: EConst(CIdent(pattern))}):
                    var patternStr = printer.printExpr(expr);
                    {name: name, pattern: patternStr}
                  case EMeta({name: name}, expr):
                    var patternStr = printer.printExpr(expr);
                    {name: name, pattern: '@_${patternStr}'}
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
      case EMeta(_, _) | EArrayDecl(_) | EBlock(_) | EBinop(OpArrow, _, _):
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

  public static function getLineNumberFromContext():Int {
    var lineStr: String = '${Context.currentPos()}';
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
      case EMeta(_, _) | EArrayDecl(_) | EBlock(_) | EBinop(OpArrow, _, _):
        acc.push(printer.printExpr(expr));
        acc;
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected package definition");
    }
  }

  #end

}