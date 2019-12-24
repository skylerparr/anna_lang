package ;
import project.AnnaLangProject;
import lang.macros.Application;
import project.ProjectConfig;
using lang.AtomSupport;
using StringTools;
using haxe.EnumTools;
using haxe.EnumTools.EnumValueTools;

@:build(lang.macros.ValueClassImpl.build())
class StandaloneRunner {
  public function new() {
  }

  public static function start(pc: ProjectConfig): Atom {
    #if !scriptable
    var annaProject: AnnaLangProject = Application.getProjectConfig('main'.atom());
    vm.Kernel.setProject(pc);
    main.Code.defineCode();
    vm.Kernel.start();
    vm.Kernel.runApplication(annaProject.autoStart);
    vm.Kernel.run();
    #end

    return 'ok'.atom();
  }
}
