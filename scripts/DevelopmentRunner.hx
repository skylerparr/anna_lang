package ;

import project.AnnaLangProject;
import lang.macros.Application;
import project.ProjectConfig;

class DevelopmentRunner {
  public static var project: ProjectConfig;

  public static function start(pc: ProjectConfig):Atom {
    project = pc;

    var annaProject: AnnaLangProject = Application.getProjectConfig('compiler');
    vm.NativeKernel.setProject(pc);
    vm.NativeKernel.setAnnaLangProject(annaProject);
    vm.NativeKernel.start();
    vm.NativeKernel.testCompiler();
    vm.NativeKernel.run();

    return Atom.create('ok');
  }

  public static function getProject(): ProjectConfig {
    return project;
  }

  public static function applicationRoot(): String {
    return Native.callStaticField("core.PathSettings", "applicationBasePath");
  }

}
