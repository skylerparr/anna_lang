package anna_unit;

import haxe.Timer;
@:build(macros.ScriptMacros.script())
class AnnaUnit {
  public static function start(testName: String = null): Void {
    if(Native.callStatic('Runtime', 'recompile', []).length == 0){
      return;
    }

    var startTime: Float = Timer.stamp();
    var clazz: Class<Dynamic> = Type.resolveClass('tests.LangParserTest');

    var fields: Array<String> = [];
    if(testName == null) {
      fields = Type.getClassFields(clazz);
    } else {
      fields.push(testName);
    }
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
    var diff: Float = (Timer.stamp() - startTime) * 1000;
    if(diff < 1) {
      cpp.Lib.println('Total Time: ${Std.int((Timer.stamp() - startTime) * 1000000)}µs');
    } else {
      cpp.Lib.println('Total Time: ${Std.int(diff)}ms');
    }
  }

}