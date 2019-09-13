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

    compileAll();
    return 'ok'.atom();
  }

  public static function getProject(): ProjectConfig {
    return project;
  }

  public static function applicationRoot(): String {
    return Native.callStaticField("core.PathSettings", "applicationBasePath");
  }

  public static function compileVMProject(): Atom {
    trace("compiling vm project");
    var annaProject: AnnaLangProject = Application.getProjectConfig('vm'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    return 'ok'.atom();
  }

  public static function compileVMAPIProject(): Atom {
    trace("compiling vm api project");
    var annaProject: AnnaLangProject = Application.getProjectConfig('vm_api'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    return 'ok'.atom();
  }

  public static function compileLangProject(): Atom {
    trace("Compiling lang project");
    var annaProject: AnnaLangProject = Application.getProjectConfig('lang'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    return 'ok'.atom();
  }

  public static function compileAcceptanceTests(): Array<String> {
    trace("Compiling acceptanceTests");
    var annaProject: AnnaLangProject = Application.getProjectConfig('acceptance_tests'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    return files;
  }

  public static function langTests(): Atom {
    cpp.Lib.println("Running lang tests");
    var annaProject: AnnaLangProject = Application.getProjectConfig('lang'.atom());
    AnnaUnit.start(annaProject.getProjectTestsConfig());
    return 'ok'.atom();
  }

  public static function vmTests(): Atom {
    cpp.Lib.println("Running vm tests");
    var annaProject: AnnaLangProject = Application.getProjectConfig('vm'.atom());
    AnnaUnit.start(annaProject.getProjectTestsConfig());
    return 'ok'.atom();
  }

  public static function compileRunner(): Void {
    cpp.Lib.println("Compiling Runner\n");
    var files = Anna.compileProject(project);
  }

  public static function compileAll(): Void {
    compileLangProject();
    compileVMAPIProject();
    compileVMProject();
    compileAcceptanceTests();
  }
}
