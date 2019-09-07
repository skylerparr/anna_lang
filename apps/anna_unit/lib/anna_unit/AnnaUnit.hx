package anna_unit;

import project.ProjectConfig;
import sys.io.File;
import util.TimeUtil;
import sys.FileSystem;
import haxe.Timer;
using StringTools;
@:build(lang.macros.ValueClassImpl.build())
class AnnaUnit {

  @field public static var failedTests: Array<String>;

  public static function start(project: ProjectConfig): Void {
    if(Anna.compileProject(project).length == 0){
      return;
    }

    if(failedTests == null) {
      failedTests = [];
    }

    var classes: Array<String> = getTests(project);
    classes = Native.callStatic('Random', 'shuffle', [classes]);
    var successCounter: Int = 0;
    var failureCounter: Int = 0;
    var startTime: Float = Timer.stamp();
    var testsToRunNextTime: Array<String> = [];

    for(className in classes) {
      var fields: Array<String> = [];
      var clazz: Class<Dynamic> = Type.resolveClass(className);
      if(failedTests.length == 0) {
        fields = Type.getClassFields(clazz);

        if(Reflect.hasField(clazz, 'start')) {
          var fun = Reflect.field(clazz, 'start');
          fun();
        }
      } else {
        fields = failedTests.copy();
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
          cpp.Lib.println('${Type.getClassName(Type.getClass(e))} message: ${e.message}');
          testsToRunNextTime.push(field);
          continue;
        }
        cpp.Lib.print('.');
      }
    }
    failedTests = testsToRunNextTime;
    cpp.Lib.println('');
    cpp.Lib.println('Success: ${successCounter} test(s).');
    if(failureCounter > 0) {
      cpp.Lib.println('Fail: ${failureCounter} test(s).');
    }
    var diff: Float = (Timer.stamp() - startTime) * 1000;
    cpp.Lib.println('Total Time: ${TimeUtil.getHumanTime(diff)}');
  }

  public static function clearFailed(): Void {
    failedTests = null;
  }

  private static function getTests(project: ProjectConfig): Array<String> {
    var testDir: String = project.srcPath;
    var files: Array<String> = FileSystem.readDirectory(testDir);
    var retVal: Array<String> = [];
    for(file in files) {
      var path = '${testDir}/${file}';
      if(FileSystem.isDirectory(path)) {
        continue;
      }
      retVal.push('${file.replace('.hx', '')}');
    }
    return retVal;
  }

}