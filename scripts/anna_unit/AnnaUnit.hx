package anna_unit;

import anna_unit.TestFailureException;
@:build(macros.ScriptMacros.script())
class AnnaUnit {
  public static function start(): Void {
    Native.callStatic('Runtime', 'recompile', []);

    var clazz: Class<Dynamic> = Type.resolveClass('tests.LangParserTest');

    var fields: Array<String> = Type.getClassFields(clazz);
    fields = Native.callStatic('Random', 'shuffle', [fields]);
    var successCounter: Int = 0;
    var failureCounter: Int = 0;
    for(field in fields) {
      if(field == "start" || field == 'main') {
        continue;
      }
      var fun = Reflect.field(clazz, field);
      try {
        Reflect.callMethod(clazz, fun, []);
        successCounter++;
      } catch(e: Dynamic) {
        failureCounter++;
        cpp.Lib.println('');
        cpp.Lib.println('failure testing ${clazz}#${field}');
        cpp.Lib.println(e.message);
        continue;
      }
      cpp.Lib.print('.');
    }
    cpp.Lib.println('');
    cpp.Lib.println('Success: ${successCounter} test(s).');
    if(failureCounter > 0) {
      cpp.Lib.println('Fail: ${failureCounter} test(s).');
    }
  }

}