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
  @field public static var project: ProjectConfig;

  public static function start(pc: ProjectConfig):Atom {
    project = pc;

    #if cppia
    compileAll(function() {
      var cls: Class<Dynamic> = Type.resolveClass('vm.NativeKernel');
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
    vm.NativeKernel.setProject(pc);
    vm.NativeKernel.setAnnaLangProject(annaProject);
    vm.NativeKernel.start();
    vm.NativeKernel.testCompiler();
    vm.NativeKernel.run();
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

  public static function compileRunner(): Void {
    trace("Compiling Runner");
    var files = Anna.compileProject(project);
  }

  public static function compileCompiler(onComplete: Void->Void = null): Void {
    trace("Compiling Compiler");
    var annaProject: AnnaLangProject = Application.getProjectConfig('compiler'.atom());
    var files = Anna.compileProject(annaProject.getProjectConfig());
    if(onComplete != null) {
      onComplete();
    }
  }

  public static function compileAll(onComplete: Void->Void = null): Void {
    compileCompiler();
    if(onComplete != null) {
      onComplete();
    }
  }
  #end
}
