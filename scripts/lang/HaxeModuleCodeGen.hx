package lang;
import TypePrinter.MapPrinter;
import ArrayEnum;
import compiler.Compiler;
import lang.CustomTypes.CustomType;
import Type.ValueType;

using lang.AtomSupport;
using lang.ArraySupport;
using StringTools;
using TypePrinter.MapPrinter;
using TypePrinter.StringPrinter;

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

class HaxeModuleCodeGen {

  private static inline var classTemplate: String = "package ::package_name::;
import lang.AtomSupport;
using lang.AtomSupport;

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
        case(module_spec):
          var class_name;
          var package_name;
          var functions;
          switch(module_spec) {
            case {class_name: _class_name, package_name: _package_name, functions: _functions}:
              class_name = _class_name;
              package_name = _package_name;
              functions = _functions;
          }
          var template = Anna.createInstance(haxe.Template, [classTemplate]);
          Native.call(template, 'execute', [
            {
              class_name: Atom.to_string(class_name),
              package_name: Anna.or(package_name, ''.atom()).value,
              functions: generate_functions(functions, v0)
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
  private static inline function generate_functions(v0: Array<FunctionSpec>, v1: ModuleSpec): Array<FunctionGen> {
    return {
      switch([v0, v1]) {
        case [functions, module_spec]:
          var funGenMap: Map<String, FunctionGen> = ArrayToMapEnum.reduce(v0, new Map<String, FunctionGen>(), function(spec: FunctionSpec, acc: Map<String, FunctionGen>): Map<String, FunctionGen> {
            var args: String = build_args_string(spec.signature);

            var matching_args: String = get_arg_string(spec.signature);
            var matching_header: String = 'return {\n      switch([${matching_args}]) {\n';
            if(matching_args == '') {
              matching_header = 'return {';
            }
            var funcGen: FunctionGen = AnnaMap.get(acc, spec.internal_name, new FunctionGen(spec.internal_name, args, get_type_string(spec.return_type), [], matching_header));

            var body: String = get_body(spec, module_spec);
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
                var fun_bodies: Array<String> = ArrayEnum.reduce(matching_bodies, [], function(body: String, acc: Array<String>): Array<String> {
                  return {
                    if(body != ']:\n          "nil".atom();') {
                      acc.push('        case [${body}');
                    }
                    acc;
                  }
                });

                if(fun_bodies.length > 0) {
                  fun_bodies.push('        case _:\n          throw new lang.FunctionClauseNotFound("Function clause not found");');
                }
                var fun_body: String = ArrayEnum.join(fun_bodies, '\n');
                if(fun_body == '') {
                  body += '\n      "nil".atom();\n    }';
                } else {
                  body += '${fun_body}\n      }\n    }';
                }
                Reflect.setField(fun_gen, 'body', body);
                return fun_gen;
              case _:
                throw new FunctionClauseNotFound("Function clause not found");
            }
          });
        case _:
          throw new UnexpectedArgumentException('this should not be possible');
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

  private static inline function get_body(v0: FunctionSpec, v1: ModuleSpec): String {
    return {
      switch([v0, v1]) {
        case [{signature: signature, body: body, return_type: return_type}, module_spec]:
          var pattern_string: Array<String> = ArrayEnum.into(signature, [], function(sig: Array<Atom>): String {
            return {
              switch(sig) {
                case [args, _]:
                  convertPatternToString(args);
                case _:
                  throw new FunctionClauseNotFound("Function clause not found");
              }
            }
          });

          var type_scope: Map<Atom, Atom> = ArrayToMapEnum.reduce(signature, new Map<Atom, Atom>(), function(arg: Array<Atom>, acc: Map<Atom, Atom>): Map<Atom, Atom> {
            switch(arg) {
              case [name, type]:
                AnnaMap.put(acc, name, type);
              case _:
                throw new FunctionClauseNotFound("Function clause not found");
            }
            return acc;
          });

          var pattern: String = ArrayEnum.join(pattern_string, ', ');
          pattern += ']:\n';
          var exprs: Array<String> = [];
          if(body.length == 0) {
            exprs.push('          "nil".atom();');
          } else {
            exprs = ArrayEnum.into(body, [], function(expr: Array<Dynamic>): String {
              return {
                switch(Type.typeof(expr)) {
                  case TClass(Array):
                    switch(expr) {
                      case [_v0, _, _v1]:
                        var _var: Atom = _v0;
                        var _args: Dynamic = _v1;
                        if(_args == 'nil'.atom()) {
                          '          ${_var.value};';
                        } else {
                          '          ${get_function_string(_var, _args, type_scope, return_type, module_spec)};';
                        }
                      case constant:
                        '          ${Anna.toHaxeString(constant)};';
                    }
                  case constant:
                    '          ${Anna.toHaxeBodyString(expr)};';
                }
              }
            });
          }
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
            var interp_value: Dynamic = Compiler.interpHaxe(value);
            switch(Type.typeof(interp_value)) {
              case TClass(Array):
                var arrayVals: Array<String> = [];
                var array: Array<Dynamic> = interp_value;
                for(v in array) {
                  var strValue: String;
                  switch(Type.typeof(v)) {
                    case TClass(haxe.ds.ObjectMap):
                      strValue = convertPatternToString('${MapPrinter.asHaxeString(v)}'.atom());
                    case _:
                      strValue = convertPatternToString('${v}'.atom());
                  }
                  arrayVals.push(strValue);
                }
                '[ ${ArrayEnum.join(arrayVals, ', ')} ]';
              case TClass(haxe.ds.ObjectMap):
                var keyVals: Array<String> = [];
                var map: Map<Dynamic, Dynamic> = interp_value;
                for(key in map.keys()) {
                  var val: Dynamic = map.get(key);
                  val = switch(Type.typeof(val)) {
                    case TClass(Array):
                      switch(val) {
                        case [name, _, meta]:
                          val = name.value;
                        case _:
                          val;
                      }
                    case _:
                      Anna.toHaxeString(val);
                  }
                  pushKeyVal(keyVals, key, val);
                }
                '{ ${keyVals.join(', ')} }';
              case t:
                '';
            }
          } else {
            var interp_value: Dynamic;
            try {
              interp_value = Compiler.interpHaxe(value);
              Anna.toHaxeString(interp_value);
            } catch(e: Dynamic) {
              value;
            }
          }
        case _:
          throw new FunctionClauseNotFound("Function clause not found");
      }
    }
  }

  private static function pushKeyVal(keyVals: Array<String>, key: Dynamic, val: Dynamic): Void {
    if(Std.is(key, Array) && key.length == 3) {
      switch(key) {
        case [varName, [], meta] if (meta.value == 'nil'):
          key = varName;
        case _:
          throw new FunctionClauseNotFound("Pattern matching with function calls is not supported.");
      }
    }
    if(Std.is(val, Array) && val.length == 3) {
      switch(val) {
        case [varName, [], meta] if (meta.value == 'nil'):
          keyVals.push('${key.value}: ${varName.value}');
        case _:
          throw new FunctionClauseNotFound("Pattern matching with function calls is not supported.");
      }
    } else {
      var strVal: String = val;
      if(Std.is(val, Atom)) {
        strVal = '{value: "${val.value}"}';
      }
      keyVals.push('${key.value}: ${strVal}');
    }
  }

  private static inline function get_function_string(v0: Atom, v1: Array<Dynamic>, v2: Map<Atom, Atom>, v3: Atom, v4: ModuleSpec): String {
    return {
      switch([v0, v1, v2, v3, v4]) {
        case [_var, args, type_scope, return_type, module_spec]:
          var module_functions = module_spec.functions;
          var args_with_index: Array<Dynamic> = ArrayEnum.with_index(args);
          var possible_type_args: Array<Array<String>> = ArrayEnum.reduce(args_with_index, [[], []], function(t_index: Array<Dynamic>, acc: Array<Array<String>>): Array<Array<String>> {
            return {
              var types: Array<String>;
              var values: Array<String>;
              switch(acc) {
                case [t, v]:
                  types = t;
                  values = v;
                case _:
                  throw new FunctionClauseNotFound("Unexpected number of arguments");
              }

              var t: Any;
              var index: Int;
              switch(t_index) {
                case [_t, _index]:
                  t = _t;
                  index = _index;
                case _:
                  throw new FunctionClauseNotFound("Unexpected number of arguments");
              }

              switch(Type.typeof(t)) {
                case ValueType.TClass(Array):
                  //fooling the haxe compiler here. This isn't the correct type
                  //but the pattern match will still succeed, it's actually
                  //Array<Dynamic>
                  var var_or_function: Array<Atom> = (t : Array<Atom>);
                  switch(var_or_function) {
                    case [name, _, {value: 'nil'}]:
                      var type: Atom = AnnaMap.get(type_scope, name, 'nil'.atom());
                      if(type == 'nil'.atom()) {
                        types.push('');
                      } else {
                        types.push(type.value);
                      }
                      values.push(name.value);
                    case [name, _, _]:
                      var function_args = (t : Array<Dynamic>)[2];
                      var funcs: Array<FunctionSpec> = get_matching_functions(module_spec, _var, args, return_type, type_scope);
                      if(funcs.length == 1) {
                        var func: FunctionSpec = ArrayEnum.at(funcs, 0, FunctionSpec.nil);
                        var arg_and_type: Array<Atom> = ArrayEnum.at(func.signature, index, []);
                        var type: Atom = ArrayEnum.at(arg_and_type, 1, 'nil'.atom());
                        var type_string = type.value;
                        if(type == 'nil'.atom()) {
                          type_string = '';
                        }
                        types.push(type_string);

                        var mod_spec = get_module(name, function_args, module_spec);
                        var fun_name_and_args = get_function_name(name, function_args);
                        switch(fun_name_and_args) {
                          case [_name, _function_args]:
                            name = _name;
                            function_args = _function_args;
                        }
                        var arg_string = get_function_string(name, function_args, type_scope, type, mod_spec);
                        values.push(arg_string);
                      } else {
                        throw new AmbiguousFunctionException('Could not find appropriate function to call for ${Anna.inspect(name)} with args ${Anna.inspect(function_args)}');
                      }
                    case badarg:
                      throw new UnexpectedArgumentException('Received unexpected ast structure ${Anna.inspect(badarg)}');
                  }
                case constType:
                  values.push(t);
                  switch(constType) {
                    case ValueType.TClass(String):
                      types.push('String');
                    case ValueType.TInt:
                      types.push('Int');
                    case ValueType.TFloat:
                      types.push('Float');
                    case ValueType.TClass(Atom):
                      types.push('Atom');
                    case _:
                      Logger.inspect(constType, 'bad!');
                  }
              }
              acc;
            }
          });
          var str_types: Array<String>;
          var str_args: Array<String>;
          switch(possible_type_args) {
            case [_v0, _v1]:
              str_types = _v0;
              str_args = _v1;
            case _:
              throw new UnexpectedArgumentException('Array size mismatch');
          }
          var return_type_string = return_type.value;
          if(return_type == 'nil'.atom()) {
            return_type_string = '';
          }
          var funcString: String = '${_var.value}_${args.length}_${ArrayEnum.join(str_types, '_')}__${return_type_string}';
          var argsString: String = '(${ArrayEnum.join(str_args, ', ')})';
          var moduleFuns: Array<String> = ArrayEnum.into(module_functions, [], function(spec: FunctionSpec): String {
            return {
              spec.internal_name;
            }
          });

          var found: FunctionSpec = ArrayEnum.find(module_functions, FunctionSpec.nil, function(funSpec: FunctionSpec): Bool {
            return funSpec.internal_name == funcString;
          });

          if(found == FunctionSpec.nil) {
            throw new FunctionClauseNotFound('No matching function found for ${_var.value}${argsString}');
          }

          var func_path: Array<String> = [];

          var package_name: String = module_spec.package_name.value;
          if(module_spec.package_name != 'nil'.atom()) {
            func_path.push(package_name);
          }
          func_path.push(module_spec.class_name.value);
          func_path.push(found.internal_name);


          '${ArrayEnum.join(func_path, '.')}${argsString}';
        case _:
          throw new UnexpectedArgumentException('This should not be possible');
      }
    }
  }

  public static inline function get_matching_functions(v0: ModuleSpec, v1: Atom, v2: Array<Dynamic>, v3: Atom, v4: Map<Atom, Atom>): Array<FunctionSpec> {
    return {
      switch([v0, v1, v2, v3, v4]) {
        case [module_spec, name, function_args, required_return, type_scope]:
          var return_string = required_return.value;
          if(required_return == 'nil'.atom()) {
            return_string = '';
          }
          var m_spec = get_module(name, function_args, module_spec);
          if(m_spec != null) {
            module_spec = m_spec;
          }
          var fun_name_and_args = get_function_name(name, function_args);
          switch(fun_name_and_args) {
            case [_name, _function_args]:
              name = _name;
              function_args = _function_args;
          }
          var functions = get_functions_by_name(module_spec, name);
          ArrayEnum.filter(functions, function(func: FunctionSpec): Bool {
            return {
              var arity: Int = function_args.length;
              var arg_types;
              try {
                arg_types = get_internal_signature_args(module_spec, func, name, function_args, type_scope);
                var fun_name: String = '${name.value}_${arity}_${ArrayEnum.join(arg_types, '_')}__${return_string}';
                (func.internal_name == fun_name);
              } catch(e: AmbiguousFunctionException) {
                false;
              }
            }
          });
      }
    }
  }

  private static function get_function_name(v0: Atom, v1: Array<Dynamic>): Array<Dynamic> {
    return {
      switch([v0, v1]) {
        case [name, function_args]:
          if(name == '.'.atom()) {
            var first_frag: Atom = function_args[1][0];
            function_args = function_args[1][2];
            var fun_and_args = get_function_name(first_frag, function_args);
            [fun_and_args[0], fun_and_args[1]];
          } else {
            [name, function_args];
          }
      }
    }
  }

  private static inline function get_module(v0: Atom, v1: Array<Dynamic>, v2: ModuleSpec): ModuleSpec {
    return {
      switch([v0, v1, v2]) {
        case [name, function_args, default_module]:
          if(name == '.'.atom()) {
            var first_frag: Atom = function_args[0][0];
            var mod_str = get_full_module_string(first_frag.value, function_args[1]);
            Module.getModule(mod_str.atom());
          } else {
            default_module;
          }
      }
    }
  }

  private static function get_full_module_string(v0: String, v1: Array<Dynamic>): String {
    return {
      switch([v0, v1]) {
        case([mod_str, ast]):
          if(ast[0] == '.'.atom()) {
            mod_str += '.${ast[2][0][0].value}';
            var new_ast = ast[2][1];
            get_full_module_string(mod_str, new_ast);
          } else {
            mod_str;
          }
      }
    }
  }

  private static inline function get_arg_types(v0: FunctionSpec): Array<String> {
    return {
      ArrayEnum.into(v0.signature, [], function(arg: Array<Atom>): String {
        return arg[1].value;
      });
    }
  }

  private static inline function get_functions_by_name(v0: ModuleSpec, v1: Atom): Array<FunctionSpec> {
    return {
      switch([v0, v1]) {
        case([{functions: functions}, function_name]):
          ArrayEnum.filter(functions, function(func: FunctionSpec): Bool {
            return func.name == function_name;
          });
      }
    }
  }

  private static inline function get_internal_signature_args(v0: ModuleSpec, v1: FunctionSpec, v2: Atom, v3: Array<Dynamic>, v4: Map<Atom, Atom>): Array<String> {
    return {
      switch([v0, v1, v2, v3, v4]) {
        case [module_spec, func_spec, name, function_args, type_scope]:
          var function_args_with_index: Array<Dynamic> = ArrayEnum.with_index(function_args);
          ArrayEnum.into(function_args_with_index, [], function(arg_with_index: Array<Dynamic>): String {
            return {
              switch(arg_with_index) {
                case [arg, index]:
                  switch(Type.typeof(arg)) {
                    case ValueType.TClass(Array):
                      switch(arg) {
                        case [var_name, _, var_args]:
                          var var_name = arg[0];
                          var var_args: Any = arg[2];
                          if(var_args == 'nil'.atom()) {
                            var type = AnnaMap.get(type_scope, var_name, 'nil'.atom());
                            var type_string = type.value;
                            if(type == 'nil'.atom()) {
                              type_string = '';
                            }
                            type_string;
                          } else {
                            var required_return = get_type_for_arg_index(func_spec, index);
                            var matching = get_matching_functions(module_spec, var_name, var_args, required_return, type_scope);
                            if(matching.length > 1) {
                              throw new AmbiguousFunctionException('Unable to find appropriate matching function for ${Anna.inspect(var_name)} with args ${Anna.inspect(var_args)}');
                            }
                            var func: FunctionSpec = ArrayEnum.at(matching, 0, FunctionSpec.nil);
                            if(func == FunctionSpec.nil) {
                              throw new AmbiguousFunctionException('Unable to find appropriate matching function for ${Anna.inspect(var_name)} with args ${Anna.inspect(var_args)}');
                            }
                            var type_string = func.return_type.value;
                            if(func.return_type == 'nil'.atom()) {
                              type_string = '';
                            }
                            type_string;
                          }
                        case _:
                          throw new UnexpectedArgumentException('This should not be possible');
                      }
                    case const:
                      var type = get_type_for_arg_index(func_spec, index);
                      if(type == 'nil'.atom()) {
                        '';
                      } else {
                        get_type(arg);
                      }
                  }
                case _:
                  throw new UnexpectedArgumentException('This should not be possible');

              }
            }
          });
      }
    }
  }

  private static inline function get_type_for_arg_index(v0: FunctionSpec, v1: Int): Atom {
    return {
      switch([v0, v1]) {
        case [{signature: signature}, index]:
          var sig: Array<Atom> = ArrayEnum.at(signature, index, ['nil'.atom(), 'nil'.atom()]);
          ArrayEnum.at(sig, 1, 'nil'.atom());
      }
    }
  }

  private static inline function get_type(val: Dynamic): String {
    return {
      switch(Type.typeof(val)) {
        case ValueType.TClass(String):
          'String';
        case ValueType.TInt:
          'Int';
        case ValueType.TFloat:
          'Float';
        case _:
          Logger.inspect(val, 'bad!');
          'nil';
      }
    }
  }
}