package lang;

@:build(macros.ScriptMacros.script())
class HaxeCodeGen {

  private static inline var classTemplate: String = "package ::packageName::;
using lang.AtomSupport;

@:build(macros.ScriptMacros.script())
class ::className:: {
::foreach functions::
  public static function ::internalName::(::signatureString::) {
    return 'nil'.atom();
  }
::end::
}";

  public static function generate(moduleSpec: ModuleSpec): String {
    var template = new haxe.Template(classTemplate);

    var functions: Array<FunctionSpec> = moduleSpec.functions;

    var args: Dynamic = {
      className: moduleSpec.className.value,
      packageName: moduleSpec.packageName.value,
      functions: functions,
    };

    var output: String = template.execute(args);
    return output;
  }

}