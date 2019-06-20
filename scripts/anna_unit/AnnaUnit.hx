package anna_unit;

import sys.FileSystem;
import haxe.Timer;
using StringTools;
class AnnaUnit {
  public static function start(testName: String = null): Void {
    if(Native.callStatic('Runtime', 'recompile', []).length == 0){
      return;
    }

    var classes: Array<String> = getTests();
    classes = Native.callStatic('Random', 'shuffle', [classes]);
    var successCounter: Int = 0;
    var failureCounter: Int = 0;
    var startTime: Float = Timer.stamp();

    for(className in classes) {
      var clazz: Class<Dynamic> = Type.resolveClass(className);

      var fields: Array<String> = [];
      if(testName == null) {
        fields = Type.getClassFields(clazz);
      } else {
        fields.push(testName);
      }

      if(Reflect.hasField(clazz, 'start')) {
        var fun = Reflect.field(clazz, 'start');
        fun();
      }

      fields = Native.callStatic('Random', 'shuffle', [fields]);

      for(field in fields) {
        if(field == 'start' || field == 'main' || field == 'setup') {
          continue;
        }
        if(!Reflect.hasField(clazz, field)) {
          continue;
        }
        if(Reflect.hasField(clazz, 'setup')) {
          var fun = Reflect.field(clazz, 'setup');
          try {
            fun();
          } catch(e: Dynamic) {
            trace(e);
          }
        }
        var fun = Reflect.field(clazz, field);
        try {
          Reflect.callMethod(clazz, fun, []);
          successCounter++;
        } catch(e: Dynamic) {
          failureCounter++;
          cpp.Lib.println('');
          cpp.Lib.println('failure testing ${clazz}#${field}');
          cpp.Lib.println('${Type.getClassName(Type.getClass(e))} message: ${e}');
          continue;
        }
        cpp.Lib.print('.');
      }
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

  private static function getTests(): Array<String> {
    var files: Array<String> = FileSystem.readDirectory('scripts/tests');
    var retVal: Array<String> = [];
    for(file in files) {
      retVal.push('tests.${file.replace('.hx', '')}');
    }
    return retVal;
  }

}