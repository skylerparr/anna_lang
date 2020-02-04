package lang.macros;
import haxe.macro.Printer;
import hscript.plus.ParserPlus;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Type.ClassType;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.MetadataEntry;
class MacroTools {
  private static var parser: ParserPlus = {
    parser = new ParserPlus();
    parser.allowTypes = true;
    parser.allowMetadata = true;
    parser;
  }

  private static var printer: Printer = new Printer();

  macro public static function line(): Expr {
    var lineStr = MacroContext.currentPos() + '';
    var lineNo: Int = Std.parseInt(lineStr.split(':')[1]);
    return Macros.haxeToExpr('${lineNo}');
  }

  public static function createClass(className: String): TypeDefinition {
    return {
      kind: TDClass(null,[],false),
      meta: [],
      name: className,
      pack: [],
      params: [],
      pos: MacroContext.currentPos(),
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
      pos: MacroContext.currentPos()
    }
  }

  public static function buildConst(value: Constant):Expr {
    return {
      expr: EConst(value),
      pos: MacroContext.currentPos()
    };
  }
  
  public static function buildExprField(ident: Expr, field: String):Expr {
    return {
      expr: EField(ident, field),
      pos: MacroContext.currentPos()
    };
  }
  
  public static function buildCall(field: Expr, params: Array<Expr>):Expr {
    return {
      expr: ECall(field, params),
      pos: MacroContext.currentPos()
    };
  }

  public static function buildReturn(ident: Expr):Expr {
    return {
      expr: EReturn(ident),
      pos: MacroContext.currentPos()
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
        pos: MacroContext.currentPos(),
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
      pos: MacroContext.currentPos()
    }
  }

  public static function buildPublicStaticFunction(name: String, params: Array<FunctionArg>, returnType: ComplexType): Field {
    var varName: String = '_${name}';

    return {
      access: [APublic, AStatic],
      kind: FFun({
        args: params,
        expr: null,
        ret: returnType
      }),
      name: name,
      pos: MacroContext.currentPos()
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
      pos: MacroContext.currentPos()
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
      pos: MacroContext.currentPos(),
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

  public static inline function getAtom(value: String):String {
    return 'Atom.create("${value}")';
  }

  public static inline function getAtomExpr(value: String):Expr {
    return { expr: ECall({ expr: EField({ expr: EConst(CIdent('Atom')), pos: MacroContext.currentPos() },
        'create'), pos: MacroContext.currentPos() },
        [{ expr: EConst(CString(value)), pos: MacroContext.currentPos() }]),
        pos: MacroContext.currentPos() }
  }

  public static inline function getTuple(value: Array<String>):String {
    return 'Tuple.create([${value.join(', ')}])';
  }

  public static inline function getList(values: Array<String>):String {
    MacroLogger.log(getListExpr(values), 'getListExpr(values)');
    return 'LList.create([${values.join(', ')}])';
  }

  public static inline function getListExpr(values: Array<String>):Expr {
    var items: Array<Expr> = [];
    for(value in values) {
      var expr = Macros.haxeToExpr(value);
      items.push(expr);
    }
    return { expr: ECall({ expr: EField({ expr: EConst(CIdent('LList')),
      pos: MacroContext.currentPos() },'create'), pos: MacroContext.currentPos() },
    [{ expr: EArrayDecl(items), pos: MacroContext.currentPos() }]), pos: MacroContext.currentPos()};
  }

  public static inline function getKeyword(values: Array<String>):String {
    return 'Keyword.create([${values.join(",")}])';
  }

  public static function getCustomType(type: String, values: Array<String>): String {
    return 'lang.AbstractCustomType.create(${type}, {${values.join(",")}})';
  }

  public static inline function getMap(values: Array<String>):String {
    var mapExprs: Array<Expr> = [];
    for(v in values) {
      mapExprs.push(Macros.haxeToExpr(v));
    }
    var fullMapExpr = EitherMacro.doGenMap({ expr: ECast({expr: EArrayDecl(mapExprs), pos: MacroContext.currentPos()},TPath({ name: 'Array', pack: [], params: [TPType(TPath({ name: 'Dynamic', pack: [], params: [] }))]})), pos: MacroContext.currentPos()});
    var strValue = printer.printExpr(fullMapExpr);
    var strValue: String = 'MMap.create(${strValue})';
    return strValue;
  }

  public static inline function getConstant(value):String {
    return 'Tuple.create([${getAtom("const")}, ${value}])';
  }

  public static inline function getVar(value):String {
    return 'Tuple.create([${getAtom("var")}, "${value}"])';
  }

  public static inline function getPinned(value):String {
    return 'Tuple.create([${getAtom("pinned")}, "${value}"])';
  }

  public static function getTypeAndValue(expr: Expr):Dynamic {
    return switch(expr.expr) {
      case EConst(CIdent(varName)):
        var const: String = MacroContext.currentModuleDef.constants.get(varName);
        if(const == null) {
          {type: 'Variable', value: getVar(varName), rawValue: varName};
        } else {
          getTypeAndValue(Macros.haxeToExpr(const));
        }
      case EConst(CString(value)):
        value = StringTools.replace(value, '"', '\\"');
        {type: "String", value: getConstant('"${value}"'), rawValue: '"${value}"'};
      case EConst(CInt(value)):
        {type: "Number", value: getConstant(value), rawValue: value};
      case EConst(CFloat(value)):
        {type: "Number", value: getConstant(value), rawValue: value};
      case EMeta({name: "atom" | "_"}, {expr: EConst(CString(value))}):
        var strValue: String = getAtom(value);
        {type: "Atom", value: getConstant(strValue), rawValue: strValue};
      case EMeta({name: "tuple"}, {expr: EArrayDecl(values)}):
        var finalValues: Array<String> = [];
        for(value in values) {
          var typeAndValue: Dynamic = getTypeAndValue(value);
          finalValues.push(typeAndValue.value);
        }
        var strValue: String = getTuple(finalValues);
        {type: "Tuple", value: getConstant(strValue), rawValue: strValue};
      case EMeta({name: "list"}, {expr: EArrayDecl(args)}):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue: Dynamic = getTypeAndValue(arg);
          listValues.push(typeAndValue.value);
        }
        var strValue: String = getList(listValues);
        {type: "LList", value: getConstant(strValue), rawValue: strValue};
      case EMeta({name: "keyword"}, {expr: EObjectDecl(args)}):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue: Dynamic = getTypeAndValue(arg.expr);
          listValues.push('${getAtom(arg.field)}, ${typeAndValue.value}');
        }
        var strValue: String = getKeyword(listValues);

        {type: "Keyword", value: getConstant(strValue), rawValue: strValue};
      case EMeta({name: "map"}, {expr: EArrayDecl(args)}):
        var listValues: Array<String> = [];
        for(arg in args) {
          switch(arg.expr) {
            case EBinop(OpArrow, key, value):
              var keyType = getTypeAndValue(key);
              var valueType = getTypeAndValue(value);
              listValues.push('${keyType.value} => ${valueType.value}');
            case _:
              throw new ParsingException('AnnaLang: Expected =>, received ${printer.printExpr(arg)}');
          }
        }
        var strValue: String = getMap([listValues.join(",")]);
        {type: "MMap", value: getTuple([getAtom("const"), '${strValue}']), rawValue: strValue};
      case EBlock(args):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue: Dynamic = getTypeAndValue(arg);
          listValues.push(typeAndValue.value);
        }
        var strValue: String = getList(listValues);
        {type: "LList", value: getConstant(strValue), rawValue: strValue};
      case EArrayDecl(args):
        var listValues: Array<String> = [];
        var isTuple: Bool = false;
        for(arg in args) {
          switch(arg.expr) {
            case EBinop(OpArrow, key, value):
              var keyType = getTypeAndValue(key);
              var valueType = getTypeAndValue(value);
              listValues.push('${keyType.value} => ${valueType.value}');
            case EMeta({name: "atom" | "_"}, {expr: EBinop(OpArrow, {expr: EConst(CString(key))}, valExpr)}):
              var valueType = getTypeAndValue(valExpr);
              listValues.push('${getAtom(key)} => ${valueType.value}');
            case _:
              try {
                var typeAndValue = extractMapValues(arg);
                listValues.push(typeAndValue.value);
              } catch(e: Dynamic) {
                isTuple = true;
                var typeAndValue = getTypeAndValue(arg);
                listValues.push(typeAndValue.value);
              }
          }
        }
        if(isTuple) {
          var strValue: String = getTuple(listValues);
          {type: "Tuple", value: getConstant(strValue), rawValue: strValue};
        } else {
          var strValue: String = getMap(listValues);
          {type: "MMap", value: getConstant(strValue), rawValue: strValue};
        }
      case EBinop(OpArrow, const, {expr: EBinop(OpAssign, pattern, rhs)}):
        var strConst: String = printer.printExpr(pattern);
        {type: "String", value: getTuple([getAtom("var"), '${strConst}']), rawValue: printer.printExpr(expr)};
      case EBinop(OpArrow, lhs, rhs):
        var lhsType = getTypeAndValue(lhs);
        var rhsType = getTypeAndValue(rhs);
        var rawValue: String = getMap(['${lhsType.value} => ${rhsType.value}']);
        {type: "MMap", value: rawValue, rawValue: rawValue};
      case EMeta({name: '__stringMatch'}, expr):
        var value: String = printer.printExpr(expr);
        {type: "String", value: value, rawValue: value};
      case EObjectDecl(args):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue: Dynamic = getTypeAndValue(arg.expr);
          listValues.push('["${arg.field}", ${typeAndValue.value}]');
        }
        var strValue: String = getKeyword(listValues);

        {type: "Keyword", value: getConstant(strValue), rawValue: strValue};
      case ECast(expr, TPath({ name: type })):
        var typeAndValue = getTypeAndValue(expr);
        {type: AnnaLang.getAlias(type), value: typeAndValue.value, rawValue: typeAndValue.value};
      case ECall({expr: EField({expr: EConst(CIdent("Atom"))}, "create")}, [{expr: EConst(CString(atom))}]):
        {type: "Atom", value: 'Tuple.create([Atom.create("const"), ${atom}])', rawValue: atom};
      case ECall({expr: EField({expr: EConst(CIdent("Tuple"))}, "create")}, [{expr: EArrayDecl(args)}]):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue = getTypeAndValue(arg);
          listValues.push(typeAndValue.value);
        }
        var strValue: String = 'Tuple.create([${listValues.join(",")}])';
        {type: "Tuple", value: 'Tuple.create([Atom.create("const"), ${strValue}])', rawValue: strValue};
      case ECall({expr: EField({expr: EConst(CIdent("LList"))}, "create")}, [{expr: EArrayDecl(args)}]):
        var listValues: Array<String> = [];
        for(arg in args) {
          var typeAndValue: Dynamic = getTypeAndValue(arg);
          listValues.push(typeAndValue.value);
        }
        var strValue: String = 'LList.create([${listValues.join(",")}])';
        {type: "LList", value: 'Tuple.create([Atom.create("const"), ${strValue}])', rawValue: strValue};
      case ECall({expr: EField({expr: EConst(CIdent("Keyword"))}, "create")}, [{expr: EArrayDecl(args)}]):
        var listValues: Array<String> = [];
        for(arg in args) {
          var innerValues: Array<String> = [];
          switch(arg.expr) {
            case EArrayDecl(args):
              for(arg in args) {
                var typeAndValue: Dynamic = getTypeAndValue(arg);
                innerValues.push(typeAndValue.value);
              }
            case _:
              throw new ParsingException("AnnaLang: unexpected datatype");
          }
          listValues.push('[${innerValues.join(',')}]');
        }
        var strValue: String = getKeyword(listValues);
        {type: "Keyword", value: 'Tuple.create([Atom.create("const"), ${strValue}])', rawValue: strValue};
      case ECall({expr: EField({expr: EConst(CIdent("MMap"))}, "create")}, [{expr: EBlock(args)}]):
        var strValue: String = printer.printExpr({expr: EBlock(args), pos: MacroContext.currentPos()});
        {type: "MMap", value: 'Tuple.create([${getAtom("const")}, ${strValue}])', rawValue: strValue};
      case EBinop(OpMod, {expr: EConst(CIdent(type))}, {expr: EObjectDecl(fields)}):
        var listValues: Array<String> = [];
        for(field in fields) {
          var typeAndValue: Dynamic = getTypeAndValue(field.expr);
          listValues.push('${field.field}: ${typeAndValue.value}');
        }
        var strValue: String = getCustomType(type, listValues);
        {type: type, value: 'Tuple.create([${getAtom("const")}, ${strValue}])', rawValue: strValue};
      case EParenthesis(e):
        getTypeAndValue(e);
      case EBinop(OpOr, lhs, rhs):
        var value = printer.printExpr(expr);
        {type: "LList", value: value, rawValue: value};
      case EUnop(OpNegBits, false, {expr: EConst(CIdent(pinnedVarName))}):
        {type: 'Variable', value: getPinned(pinnedVarName), rawValue: pinnedVarName};
      case e:
        MacroLogger.log(expr, 'expr');
        MacroLogger.logExpr(expr, 'expr code');
        throw new ParsingException("AnnaLang: Expected type and value or variable name");
    }
  }

  public static function getCustomTypeAndValue(expr: Expr):Dynamic {
    return switch(expr.expr) {
      case EObjectDecl(items):
        var keyValues: Array<String> = [];
        for(item in items) {
          var typeAndValue = getTypeAndValue(item.expr);
          var rawValue = switch(item.expr.expr) {
            case EConst(CIdent(_)):
              typeAndValue.value;
            case _:
              typeAndValue.value;
          }
          keyValues.push('${item.field}: ${rawValue}');
        }
        var strValue: String = '{${keyValues.join(', ')}}';
        {type: "CustomType", value: getTuple([getAtom("const"), '${strValue}']), rawValue: strValue};
      case _:
        throw new ParsingException('AnnaLang: Attempting to create CustomType with incorrect declaration. Expects: YourType%{foo: "bar", baz: "cat"}');
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
        listValues.push(typeAndValue.value);
      case EMeta({name: "map"}, {expr: EBinop(OpArrow, key, value)}):
        // special case for when map has map keys
        var keyType = getTypeAndValue(key);
        var valueType = getTypeAndValue(value);
        listValues.push('${keyType.rawValue} => ${valueType.rawValue}');
      case EMeta({name: "map"}, {expr: EArrayDecl(values)}):
        var typeAndValues: Array<Dynamic> = [];
        for(v in values) {
          var typeAndValue = extractMapValues(v);
          typeAndValues.push(typeAndValue.value);
        }
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException('AnnaLang: Unexpected key ${printer.printExpr(arg)}');
    }
    var strValue: String = getMap([listValues.join(",")]);
    return {type: "MMap", value: getTuple([getAtom("const"), '${strValue}']), rawValue: strValue};
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
                    {name: name, pattern: name, isPatternVar: false}
                  case EConst(CInt(pattern)) | EConst(CString(pattern)) | EConst(CFloat(pattern)):
                    var name = util.StringUtil.random();
                    {name: name, pattern: pattern, isPatternVar: false};
                  case EObjectDecl(values):
                    var name = util.StringUtil.random();
                    var items: Array<String> = [];
                    for(value in values) {
                      var typeAndValue = getTypeAndValue(value.expr);
                      items.push('[${getAtom(value.field)}, ${getConstant(typeAndValue.value)}]');
                    }
                    {name: name, pattern: getKeyword(items), isPatternVar: false};
                  case EArrayDecl(values):
                    var name = util.StringUtil.random();
                    var items: Array<String> = [];
                    var type: String = 'tuple';
                    for(value in values) {
                      switch(value.expr) {
                        case EBinop(OpArrow, key, value):
                          type = 'map';
                          var lhsType = getTypeAndValue(key);
                          var rhsType = getTypeAndValue(value);
                          items.push('${lhsType.value} => ${rhsType.value}');
                        case _:
                          items.push(printer.printExpr(value));
                      }
                    }
                    if(type == 'tuple') {
                      var haxeStr: String = getTuple(items);
                      {name: name, pattern: haxeStr, isPatternVar: false};
                    } else {
                      var haxeStr: String = getMap(items);
                      {name: name, pattern: haxeStr, isPatternVar: false};
                    }
                  case EBlock(values):
                    var name = util.StringUtil.random();
                    var items: Array<String> = [];
                    for(value in values) {
                      items.push(printer.printExpr(value));
                    }
                    var haxeStr: String = getList(items);
                    {name: name, pattern: haxeStr, isPatternVar: false};
                  case EBinop(OpArrow, {expr: EConst(CString(name))}, {expr: EConst(CIdent(pattern))}):
                    var patternStr = printer.printExpr(expr);
                    retVal.argTypes.push({type: 'String', name: pattern, pattern: pattern, isPatternVar: true});

                    {name: name, pattern: patternStr, isPatternVar: false}
                  case EMeta({name: name}, expr):
                    var patternStr = printer.printExpr(expr);
                    {name: name, pattern: '@_${patternStr}', isPatternVar: false}
                  case EBinop(OpMod, {expr: EConst(CIdent(name))}, {expr: EObjectDecl(customValueTypes)}):
                    var items: Array<String> = [];
                    for(value in customValueTypes) {
                      var typeAndValue = getTypeAndValue(value.expr);
                      items.push('${value.field}: ${typeAndValue.value}');
                    }
                    {name: name, pattern: getCustomType(name, items), isPatternVar: false};
                  case e:
                    MacroLogger.log(e, 'e');
                    throw new ParsingException("AnnaLang: expected variable or pattern");
                }
                retVal.argTypes.push({type: value.field, name: nameAndPattern.name, pattern: nameAndPattern.pattern, isPatternVar: nameAndPattern.isPatternVar});
              }
            case EArrayDecl(returnTypes):
              for(returnType in returnTypes) {
                retVal.returnTypes.push(AnnaLang.getAlias(getIdent(returnType)));
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
    var type: Type = MacroContext.typeof(expr);
    return switch(type) {
      case TInst(t, other):
        switch(t.get().interfaces) {
          case _:
            t.toString();
        }
      case TAbstract(t, _):
        t.toString();
      case TDynamic(_):
        "Dynamic";
      case TType(t, _):
        t.toString();
      case TLazy(_):
        getIdent(expr);
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
      case EMeta(_, _) | EArrayDecl(_) | EBlock(_) | EBinop(OpArrow, _, _) | EObjectDecl(_):
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
    var lineStr: String = '${MacroContext.currentPos()}';
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
      case EMeta(_, _) | EArrayDecl(_) | EBlock(_) | EBinop(OpArrow, _, _) | EObjectDecl(_):
        acc.push(printer.printExpr(expr));
        acc;
      case e:
        MacroLogger.log(e, 'e');
        throw new ParsingException("AnnaLang: Expected package definition");
    }
  }

}