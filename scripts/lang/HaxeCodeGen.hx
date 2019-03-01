package lang;
import lang.CustomTypes.CustomType;
import haxe.Template;
import Type.ValueType;

using lang.AtomSupport;
using lang.ArraySupport;
using StringTools;

class FunctionGen implements CustomType {
  public var internal_name(default, never): String;
  public var signature_string(default, never): String;
  public var return_type_string(default, never): String;
  public var body(default, never): String;

  public inline function new(internal_name: String, signature_string: String, return_type_string: String, body: String) {
    Reflect.setField(this, 'internal_name', internal_name);
    Reflect.setField(this, 'signature_string', signature_string);
    Reflect.setField(this, 'return_type_string', return_type_string);
    Reflect.setField(this, 'body', body);
  }
}

@:build(macros.ScriptMacros.script())
class HaxeCodeGen {

  private static inline var classTemplate: String = "package ::package_name::;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class ::class_name:: {
::foreach functions::
  public static function ::internal_name::(::signature_string::)::return_type_string:: {
    ::body::
  }
::end::
}";

  /*
   * @spec(generate, {lang.ModuleSpec}, String)
   * def generate(%lang.ModuleSpec{module_name: module_name, package_name: package_name, functions: functions}) do
   *   template = Anna.createInstance(haxe.Template, [@classTemplate])
   *   Native.call(template, "execute", {%{
   *     "class_name" => Atom.to_string(class_name),
   *     "package_name" => get_package_string(package_name),
   *     "functions" => generate_functions(functions)
   *   }})
   * end
   *
   */
  public static function generate(v0: lang.ModuleSpec): String {
    return {
      switch(v0) {
        case({class_name: class_name, package_name: package_name, functions: functions}):
          var template = Anna.createInstance(haxe.Template, [classTemplate]);
          Native.call(template, 'execute', [
            {
              class_name: Atom.to_string(class_name),
              package_name: Anna.or(package_name, ''.atom()).value,
              functions: generate_functions(functions)
            }
          ]);
      }
    };
  }

  /*
    @spec(generate_functions, {Array<lang.FunctionSpec>}, Array<lang.FunctionGen>)
    def generate_functions(functions) do
      Enum.reduce(functions, [], fn(%lang.FunctionSpec{"internal_name" => internal_name}) ->

      end)
    end
   */
  private static inline function generate_functions(v0: Array<FunctionSpec>): Array<FunctionGen> {
    return {
      switch(v0) {
        case functions:
          ArrayEnum.reduce(v0, new Array<FunctionGen>(), function(spec: FunctionSpec, acc: Array<FunctionGen>): Array<FunctionGen> {
            var args: String = build_args_string(spec.signature);
            acc.push(new FunctionGen(spec.internal_name, args, get_type_string(spec.return_type), get_body(spec.body)));
            return acc;
          });
      }
    }
  }

  public static inline function build_args_string(v0: Array<Array<Atom>>): String {
    return {
      switch(v0) {
        case args:
          ArrayEnum.join(ArrayEnum.into(args, new Array<String>(), function(item: Array<Atom>): String {
            return {
              switch(item) {
                case [name, type]:
                  var type_str: String = get_type_string(type);
                  var name_str: String = Atom.to_string(name);
                  '${name_str}${type_str}';
                case _:
                  throw new FunctionNotFoundException("Could not find matching function clause");
              }
            }
          }), ", ");
      }
    }
  }

  private static inline function get_type_string(v0: Atom): String {
    return {
      switch(v0) {
        case {value: 'nil'}:
          '';
        case type:
          ': ${type.value}';
      }
    }
  }

  private static inline function get_body(v0: Array<Dynamic>): String {
    return {
      switch(v0) {
        case body:
          return 'return {
      "nil".atom();
    }';
      }
    }
  }

}