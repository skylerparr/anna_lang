package ;

import anna_unit.AnnaUnit;
import hscript.Interp;
import hscript.Parser;
import project.DefaultProjectConfig;
import project.ProjectConfig;
import Reflect;
import String;
using lang.AtomSupport;
using StringTools;
using haxe.EnumTools;
using haxe.EnumTools.EnumValueTools;

@:build(lang.macros.ValueClassImpl.build())
class Runner {
  @field public static var parser: Parser;
  @field public static var interp: Interp;
  @field public static var project: ProjectConfig;

  public static function start(pc: ProjectConfig):Atom {
    project = pc;

    parser = Native.callStaticField('Main', 'parser');
    interp = Native.callStaticField('Main', 'interp');
    interp.variables.set("AnnaUnit", AnnaUnit);
    Reflect.field(AnnaUnit, "main")();

//    Reflect.field(Classes, "main")();
//    Reflect.field(Inspector, "main")();
//    Reflect.field(Kernel, "main")();
//    Reflect.field(UntestedScheduler, "main")();
    return 'ok'.atom();
  }

  public static function getProject(): ProjectConfig {
    return project;
  }

  public static function applicationRoot(): String {
    return Native.callStaticField("core.PathSettings", "applicationBasePath");
  }

  public static function vmProjectTests(): Atom {
    cpp.Lib.println("run vm project tests");
    var appRoot: String = applicationRoot();
    var project: ProjectConfig = new DefaultProjectConfig("VM", '${appRoot}apps/vm/test', 'out/',
    ['${appRoot}src/', '${appRoot}apps/lang/lib', '${appRoot}apps/vm/lib', '${appRoot}apps/anna_unit/lib'],
    ['hscript-plus', 'sepia', 'mockatoo']
    );
    AnnaUnit.start(project);
    return 'ok'.atom();
  }

  public static function langProjectTests(): Atom {
    cpp.Lib.println("run lang project tests");
    var appRoot: String = applicationRoot();
    var project: ProjectConfig = new DefaultProjectConfig("Lang", '${appRoot}apps/lang/test', 'out/',
    ['${appRoot}src/', '${appRoot}apps/vm/lib', '${appRoot}apps/lang/lib', '${appRoot}apps/anna_unit/lib'],
    ['hscript-plus', 'sepia', 'mockatoo']
    );
    AnnaUnit.start(project);
    return 'ok'.atom();
  }

  public static function compileAcceptanceTests(): Array<String> {
    cpp.Lib.println("Compiling acceptanceTests");
    var appRoot: String = applicationRoot();
    var project: ProjectConfig = new DefaultProjectConfig("AcceptanceTests", '${appRoot}apps/acceptance_tests/lib', 'out/',
          ['${appRoot}src/', '${appRoot}apps/lang/lib', '${appRoot}apps/vm/lib'],
          ['hscript-plus', 'sepia']
    );
    var files = Anna.compileProject(project);
    return files;
  }

  public static function compileRunner(): Void {
    cpp.Lib.println("Compiling Runner");
    var files = Anna.compileProject(project);
  }

  public static function runAll(): Void {
    compileRunner();
    compileAcceptanceTests();
    langProjectTests();
    vmProjectTests();
  }
}
