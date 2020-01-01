package ;

import project.AnnaLangProject;
import lang.macros.Application;
import hscript.Interp;
import hscript.Parser;
import project.DefaultProjectConfig;
import project.ProjectConfig;
import String;
using lang.AtomSupport;
using StringTools;
using haxe.EnumTools;
using haxe.EnumTools.EnumValueTools;

@:build(lang.macros.ValueClassImpl.build())
class DevelopmentRunner {
  @field public static var parser: Parser;
  @field public static var interp: Interp;
  @field public static var project: ProjectConfig;

  public static function start(pc: ProjectConfig):Atom {
    project = pc;

    #if cppia
    parser = Native.callStaticField('Main', 'parser');
    interp = Native.callStaticField('Main', 'interp');
    interp.variables.set("AnnaUnit", anna_unit.AnnaUnit);
    Reflect.field(anna_unit.AnnaUnit, "main")();
    compileAll(function() {
      defineCode();
      var cls: Class<Dynamic> = Type.resolveClass('vm.Kernel');
      if(cls == null) {
        trace('Kernel is missing?');
        return;
      }
      Reflect.callMethod(null, Reflect.field(cls, 'setProject'), [pc]);
      Reflect.callMethod(null, Reflect.field(cls, 'start'), []);
      Reflect.callMethod(null, Reflect.field(cls, 'testCompiler'), []);
      Reflect.callMethod(null, Reflect.field(cls, 'run'), []);
    });
    #else
    var annaProject: AnnaLangProject = Application.getProjectConfig('compiler'.atom());
    vm.Kernel.setProject(pc);
    Code.defineCode();
    vm.Kernel.start();
    vm.Kernel.testCompiler();
    vm.Kernel.run();
    #end

    return 'ok'.atom();
  }

  private static function defineCode(): Atom {
    // not sure what to do with this yet. Going to save this here for now.
    #if cppia
      var cls: Class<Dynamic> = Type.resolveClass('Code');
      if(cls == null) {
        trace('Module Code was not found');
        return 'error'.atom();
      }
      Reflect.callMethod(null, Reflect.field(cls, 'defineCode'), []);
    #end
    return 'ok'.atom();
  }

  public static function getProject(): ProjectConfig {
    return project;
  }

  public static function applicationRoot(): String {
    return Native.callStaticField("core.PathSettings", "applicationBasePath");
  }

  #if cppia
  public static function compileVMProject(onComplete: Void->Void = null): Atom {
    trace("Compiling vm");
    var annaProject: AnnaLangProject = Application.getProjectConfig('vm'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    if(onComplete != null) {
      onComplete();
    }
    return 'ok'.atom();
  }

  public static function compileVMAPIProject(): Atom {
    trace("Compiling vm api");
    var annaProject: AnnaLangProject = Application.getProjectConfig('vm_api'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    return 'ok'.atom();
  }

  public static function compileLangProject(): Atom {
    trace("Compiling lang");
    var annaProject: AnnaLangProject = Application.getProjectConfig('lang'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    return 'ok'.atom();
  }

  public static function compileAcceptanceTests(): Array<String> {
    trace("Compiling AcceptanceTests");
    var annaProject: AnnaLangProject = Application.getProjectConfig('acceptance_tests'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    return files;
  }

  public static function langTests(): Atom {
    trace("Running lang tests");
    var annaProject: AnnaLangProject = Application.getProjectConfig('lang'.atom());
    anna_unit.AnnaUnit.start(annaProject.getProjectTestsConfig());
    return 'ok'.atom();
  }

  public static function vmTests(): Atom {
    trace("Running vm tests");
    var annaProject: AnnaLangProject = Application.getProjectConfig('vm'.atom());
    anna_unit.AnnaUnit.start(annaProject.getProjectTestsConfig());
    return 'ok'.atom();
  }

  public static function compileRunner(): Void {
    trace("Compiling Runner");
    var files = Anna.compileProject(project);
  }

  public static function compileCompiler(onComplete: Void->Void = null): Void {
    trace("Compiling Compiler");
    var annaProject: AnnaLangProject = Application.getProjectConfig('compiler'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    defineCode();
    if(onComplete != null) {
      onComplete();
    }
  }

  public static function compileAll(onComplete: Void->Void = null): Void {
    compileLangProject();
    compileVMAPIProject();
    compileVMProject();
    compileCompiler();
//    #if startHaxe
    compileAcceptanceTests();
//    #end
    if(onComplete != null) {
      onComplete();
    }
  }
  #end
}
