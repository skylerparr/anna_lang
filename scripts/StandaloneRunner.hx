package ;
import project.AnnaLangProject;
import lang.macros.Application;
import project.ProjectConfig;
using lang.AtomSupport;
using StringTools;
using haxe.EnumTools;
using haxe.EnumTools.EnumValueTools;

class StandaloneRunner {
  public function new() {
  }

  public static function start(pc: ProjectConfig): Atom {
    #if !scriptable
    var annaProject: AnnaLangProject = Application.getProjectConfig('my_app'.atom());
    vm.NativeKernel.setProject(pc);
    Code.defineCode();
    vm.NativeKernel.start();
    vm.NativeKernel.runApplication(annaProject.autoStart);
    vm.NativeKernel.run();
    #end

    return 'ok'.atom();
  }
}
