package lang.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.Ref;

class ValueClassImpl {

  macro public static function build(): Array<Field> {
    MacroLogger.log("=====================");
    MacroLogger.log('Macros: ${Context.getLocalClass()}');

    var fields: Array<Field> = Context.getBuildFields();

    var p: Printer = new Printer();

    var classType: Null<Ref<ClassType>> = Context.getLocalClass();
    var className: String = classType.toString();
    var frags: Array<String> = className.split('.');
    var shortClass: String = frags[frags.length - 1];

    //create the global module interaction
    var moduleField = {
      name: "module",
      access: [APrivate, AStatic, AInline],
      pos: Context.currentPos(),
      kind: FVar(null, macro $v{className} )
    };

    fields.push(moduleField);

    var field = {
      name: "main",
      access: [APublic, AStatic],
      pos: Context.currentPos(),
      kind: FFun({
        args: [],
        expr: macro {
          state.GlobalState.init(module, {});
        },
        params: [],
        ret: null
      })
    }

    fields.push(field);

    field = {
      name: "getState",
      access: [APublic, AStatic],
      pos: Context.currentPos(),
      kind: FFun({
        args: [],
        expr: macro {
          return state.GlobalState.get(module);
        },
        params: [],
        ret: (macro:Dynamic)
      })
    }

    fields.push(field);


    //add the fields
    for(field in fields) {
      var metas: Null<Metadata> = field.meta;
      switch metas {
        case null:
          null;
        case []:
        case meta:
          var fieldName: String = field.name;
          var type: Null<ComplexType> = getType(field.kind);
          var getFun:Function = {
            expr: macro return Reflect.field(getState(), $v{fieldName}),
            ret: type,
            args:[]
          };
          var setFun:Function = {
            expr: macro {
              Reflect.setProperty(getState(), $v{fieldName}, value);
              return value;
            },
            ret: type,
            args:[{name: 'value', type: type}]
          };

          field.access = [APublic, AStatic];
          field.kind = FieldType.FProp("get", "set", getFun.ret);

          var getterField:Field = {
            name: "get_" + field.name,
            access: [Access.APrivate, Access.AStatic],
            kind: FieldType.FFun(getFun),
            pos: field.pos,
          };

          var setterField:Field = {
            name: "set_" + field.name,
            access: [Access.APrivate, Access.AStatic],
            kind: FieldType.FFun(setFun),
            pos: field.pos,
          };

          fields.push(getterField);
          fields.push(setterField);
      }
    }

    MacroLogger.log("---------------------");
    MacroLogger.printFields(fields);
    MacroLogger.log("_____________________");
    return fields;
  }

  private static function getType(field: FieldType): Null<ComplexType> {
    switch(field) {
      case FVar(type):
        return type;
      case _:
        return null;
    }
  }

}
