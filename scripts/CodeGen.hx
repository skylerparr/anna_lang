package;

import haxe.Template;
class CodeGen {

  private static inline var t: String = "
@:generic
class Tuple::counter::<::types::> extends Tuple implements CustomType {
  ::foreach vars::
  public var ::varname::(default, never): ::type::;::end::

  public inline function new(::constructor::) {::foreach vars::
    Reflect.setField(this, 'var::counter::', var::counter::);::end::
  }

  private inline function asArray(): Array<Any> {
    return [::varNames::];
  }

  public function toAnnaString(): String {
    var stringFrags: Array<String> = [];
    var vars: Array<Any> = asArray();
    for(v in vars) {
      stringFrags.push(Anna.toAnnaString(v));
    }
    return '{${stringFrags.join(', ')}}';
  }

  public function toHaxeString(): String {
    var stringFrags: Array<String> = [];
    var vars: Array<Any> = asArray();
    for(v in vars) {
      stringFrags.push(Anna.toHaxeString(v));
    }
    return 'Tuple.create([${stringFrags.join(', ')}]);';
  }

  public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
    if(patternArgs == null) {
      patternArgs = [];
    }
    var retVal: Array<String> = [];
    for(pattern in patternArgs) {
      retVal.push('${pattern.key}: ${pattern.value}');
    }
    return '{${retVal.join(', ')}}';
  }
}";

  private static inline var alphabet: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  public static function generate(): Void {
    var template: Template = new Template(t);

    var types: Array<String> = [];
    var all: Array<String> = [];

    for(i in 0...alphabet.length) {
      types.push(alphabet.charAt(i));

      var vars: Array<Dynamic> = [];
      var constructor: Array<String> = [];
      var varNames: Array<String> = [];

      for(j in 0...types.length) {
        var type = types[j];
        var counter: Int = j + 1;
        var varname: String = 'var${counter}';
        var variable: Dynamic = {type: type, varname: varname, counter: counter};
        vars.push(variable);
        varNames.push(varname);
        constructor.push('var${counter}: ${type}');
      }

      var context: Dynamic = {
        counter: i + 1,
        types: types.join(', '),
        vars: vars,
        varNames: varNames.join(', '),
        constructor: constructor.join(', ')
      };

      var string = template.execute(context);
      all.push(string);
    }

    Logger.inspect(all.join('\n'));
  }

  private static inline var createString: String = '
    switch(val) {
      ::foreach args::
      case [::argValues::]:
        new Tuple::size::(::constructorArgs::);::end::
    }
';

  public static function gen(): Void {
    var t: Template = new Template(createString);
    var args: Array<Dynamic> = [];

    for(i in 0...alphabet.length) {
      var size: Int = i + 1;
      var argValues: Array<String> = [];
      var constructorArgs: Array<String> = [];
      for(j in 0...size) {
        var argId: Int = j + 1;
        argValues.push('var${argId}');
        constructorArgs.push('var${argId}');
      }
      var arg: Dynamic = {argValues: argValues.join(', '), size: size, constructorArgs: constructorArgs.join(', ')};
      args.push(arg);
    }

    var result: String = t.execute({
      args: args
    });

    Logger.inspect(result);
  }
}