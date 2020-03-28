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
    vm.NativeKernel.setProject(pc);
    main.Code.defineCode();
    vm.NativeKernel.start();
    vm.NativeKernel.runApplication(annaProject.autoStart);
    vm.NativeKernel.run();
    #end

    return 'ok'.atom();
  }
}
