package lang;
import haxe.ds.ObjectMap;
import compiler.Compiler;
import ArrayEnum;
import lang.CustomTypes.CustomType;
import haxe.Template;
import Type.ValueType;

using lang.AtomSupport;
using lang.ArraySupport;
using StringTools;
using TypePrinter.MapPrinter;

class FunctionGen implements CustomType {
  public var internal_name(default, never): String;
  public var signature_string(default, never): String;
  public var return_type_string(default, never): String;
  public var matching_bodies(default, never): Array<String>;
  public var body(default, never): String;

  public inline function new(internal_name: String, signature_string: String, return_type_string: String, matching_bodies: Array<String>, body: String) {
    Reflect.setField(this, 'internal_name', internal_name);
    Reflect.setField(this, 'signature_string', signature_string);
    Reflect.setField(this, 'return_type_string', return_type_string);
    Reflect.setField(this, 'matching_bodies', matching_bodies);
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
          var funGenMap: Map<String, FunctionGen> = ArrayToMapEnum.reduce(v0, new Map<String, FunctionGen>(), function(spec: FunctionSpec, acc: Map<String, FunctionGen>): Map<String, FunctionGen> {
            var args: String = build_args_string(spec.signature);

            var matching_header: String = 'return {\n      switch([${get_arg_string(spec.signature)}]) {\n';
            var funcGen: FunctionGen = AnnaMap.get(acc, spec.internal_name, new FunctionGen(spec.internal_name, args, get_type_string(spec.return_type), [], matching_header));

            var body: String = get_body(spec);
            funcGen.matching_bodies.push(body);

            acc = AnnaMap.put(acc, spec.internal_name, funcGen);
            return acc;
          });
          MapToArrayEnum.into(funGenMap, [], function(kv: KeyValue<String, FunctionGen>): FunctionGen {
            switch(kv) {
              case {key: key, value: fun_gen}:
                var matching_bodies;
                var body;
                {
                  switch(fun_gen) {
                    case {matching_bodies: _v0, body: _v1}:
                      matching_bodies = _v0;
                      body = _v1;
                    case _:
                      throw new FunctionClauseNotFound("Function clause not found");
                  }
                }
                var fun_body: String = ArrayEnum.join(matching_bodies, '\n');
                body += '        case [${fun_body}\n      }\n    }';
                Reflect.setField(fun_gen, 'body', body);
                return fun_gen;
              case _:
                throw new FunctionClauseNotFound("Function clause not found");
            }
          });
      }
    }
  }

  private static inline function build_args_string(v0: Array<Array<Atom>>): String {
    return {
      switch(v0) {
        case args:
          ArrayEnum.join(ArrayEnum.into(ArrayEnum.with_index(args), [], function(item: Array<Dynamic>): String {
            return {
              switch(item) {
                case [[_, type], index]:
                  var type_str: String = get_type_string(type);
                  'v${index}${type_str}';
                case _:
                  throw new FunctionClauseNotFound("Could not find matching function clause");
              }
            }
          }), ", ");
      }
    }
  }

  private static inline function get_arg_string(v0: Array<Array<Atom>>): String {
    return {
      switch(v0) {
        case args:
          ArrayEnum.join(ArrayEnum.into(ArrayEnum.with_index(args), [], function(item: Array<Dynamic>): String {
            return {
              switch(item) {
                case [_, index]:
                  'v${index}';
                case _:
                  throw new FunctionClauseNotFound("Could not find matching function clause");
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

  private static inline function get_body(v0: FunctionSpec): String {
    return {
      switch(v0) {
        case {signature: signature, body: body}:
          var pattern_string: Array<String> = ArrayEnum.into(signature, [], function(sig: Array<Atom>): String {
            return {
              switch(sig) {
                case [args, _]:
                  var patternHeader: String = convertPatternToString(args);
                  patternHeader;
                case _:
                  throw new FunctionClauseNotFound("Function clause not found");
              }
            }
          });

          var pattern: String = ArrayEnum.join(pattern_string, ', ');
          pattern += ']:\n';

          var exprs: Array<String> = ArrayEnum.into(body, [], function(expr: Array<Dynamic>): String {
            return {
              switch(expr) {
                case [_v0, [], _v1]:
                  var _var: Atom = _v0;
                  var _args: Atom = _v1;
                  '          ${_var.value};';
                case _:
                  throw new FunctionClauseNotFound("Function clause not found");
              }
            }
          });

          pattern + ArrayEnum.join(exprs, '\n');
        case _:
          throw new FunctionClauseNotFound("Function clause not found");
      }
    }
  }

  private static inline function convertPatternToString(v0: Atom): String {
    return {
      switch(v0) {
        case {value: value}:
          if(value.startsWith('[')) {
            var map: Map<Dynamic, Dynamic> = Compiler.interpHaxe(value);
            var keyVals: Array<String> = [];
            for(key in map.keys()) {
              var val: Dynamic = map.get(key);
              if(Std.is(val, Atom)) {
                val = cast(val, Atom).value;
              }
              pushKeyVal(keyVals, key, val);
            }
            '{ ${keyVals.join(', ')} }';
          } else {
            value;
          }
        case _:
          throw new FunctionClauseNotFound("Function clause not found");
      }
    }
  }

  private static function pushKeyVal(keyVals: Array<String>, key: Dynamic, val: Dynamic): Void {
    if(Std.is(val, Array) && val.length == 3) {
      switch(val) {
        case [varName, [], meta] if (meta.value == 'nil'):
          keyVals.push('${key.value}: ${varName.value}');
        case _:
          throw new FunctionClauseNotFound("Pattern matching with function calls is not supported.");
      }
    } else {
      keyVals.push('${key}: ${val}');
    }
  }
}