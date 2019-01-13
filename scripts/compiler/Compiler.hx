package compiler;

typedef Arg = {
  name: String,
  type: String
}

@:build(macros.ScriptMacros.script())
class Compiler {

  public static var parser: Dynamic;
  public static var interp: Dynamic;

  public static function compile(string: String, args: Array<Arg>): Void {
    var arrArgs: Array<String> = [];
    for(arg in args) {
      arrArgs.push('${arg.name}');
    }

    var retVal = 'function ${string}(${arrArgs.join(",")}) {
      return ${args[0].name};
    }';

    var ast = parser.parseString(retVal);
    interp.execute(ast);
  }

}