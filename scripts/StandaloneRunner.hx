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
    //var annaProject: AnnaLangProject = Application.getProjectConfig('my_app'.atom());
    var annaProject: AnnaLangProject = Application.getProjectConfig('main'.atom());
    vm.NativeKernel.setProject(pc);
    vm.NativeKernel.setAnnaLangProject(annaProject);
    Code.defineCode();
    vm.NativeKernel.start();
    if(vm.Classes.defined("Kernel".atom()) == "false".atom()) {
      vm.NativeKernel.runApplication("CompilerMain"); 
    } else {
      vm.NativeKernel.runApplication(annaProject.autoStart);
    }
    vm.NativeKernel.run();
    #end

    return 'ok'.atom();
  }
}
