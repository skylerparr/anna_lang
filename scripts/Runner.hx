package ;

import project.AnnaLangProject;
import lang.macros.Application;
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
//    var project: ProjectConfig = Application.defineApplication("VM", 'apps/vm/test', 'out/',
//    ['src/', 'apps/lang/lib', 'apps/vm/lib', 'apps/anna_unit/lib'],
//    ['hscript-plus', 'sepia', 'mockatoo']
//    );
    AnnaUnit.start(project);
    return 'ok'.atom();
  }

  public static function langProjectTests(): Atom {
    cpp.Lib.println("run lang project tests");
//    var project: ProjectConfig = Application.defineApplication("Lang", 'apps/lang/test', 'out/',
//    ['src/', 'apps/vm/lib', 'apps/lang/lib', 'apps/anna_unit/lib'],
//    ['hscript-plus', 'sepia', 'mockatoo']
//    );
    AnnaUnit.start(project);
    return 'ok'.atom();
  }

  public static function compileAcceptanceTests(): Array<String> {
    cpp.Lib.println("Compiling acceptanceTests");
    var annaProject: AnnaLangProject = Application.getProjectConfig('acceptance_tests'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
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
