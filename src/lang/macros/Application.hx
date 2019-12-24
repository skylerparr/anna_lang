package lang.macros;

#if macro
import haxe.Template;
import sys.FileSystem;
import sys.io.File;
import lang.macros.Macros;
import lang.macros.MacroTools;
import haxe.macro.Context;
import lang.macros.MacroLogger;
import haxe.macro.Expr;
import haxe.macro.Printer;
#end
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Json;
class Application {
  private static inline var APP_DIR: String = 'apps/';
  private static inline var CONFIG_FILE: String = 'app_config.json';

  macro public static function getProjectConfig(appAtomName: Expr): Expr {
    var appName: String = getAtomValue(appAtomName);
    var config: Dynamic = fetchAppConfigByName(appName);

    var appNameExpr: Expr = Macros.haxeToExpr('"${appName}".atom()');
    var autoStart: Expr = Macros.haxeToExpr('"${config.autoStart}"');
    var configApps: Array<String> = cast config.apps;
    var apps: Array<String> = [];
    for(app in configApps) {
      apps.push('"${app}"');
    }
    var appsExpr: Expr = Macros.haxeToExpr('[${apps.join(",")}]');
    var haxelibsStr: String = '';
    var haxelibs: Array<Dynamic> = cast(config.haxelibs, Array<Dynamic>);
    for(lib in haxelibs) {
      haxelibsStr += ', "${lib}"';
    }

    var haxeLibs: Expr = Macros.haxeToExpr('["hscript-plus", "sepia", "mockatoo"${haxelibsStr}]');
    var includeClasses: Array<String> = [];
    #if !scriptable
    includeClasses = getClassesToInclude(appDir(appName + '/lib/'));
    includeClasses = includeClasses.concat(getClassesToInclude(appDir(appName + '/test/')));
    #end

    var includeExpr: Expr = Macros.haxeToExpr('${includeClasses.join(';')}');
    return macro {
      $e{includeExpr}
      var appRoot: String = Native.callStaticField("core.PathSettings", "applicationBasePath");
      new project.AnnaLangProject(appRoot, $e{appNameExpr}, $e{autoStart}, $e{appsExpr}, [], $e{haxeLibs});
    }
  }

  #if macro
  private static function appDir(appName: String): String {
    return '${APP_DIR}${appName}';
  }

  private static function fetchAppConfigByName(appName: String): Dynamic {
    var strConfig: String = File.getContent('${appDir(appName)}/${CONFIG_FILE}');
    return Json.parse(strConfig);
  }

  private static function getAtomValue(expr: Expr): String {
    return switch(expr.expr) {
      case ECall({ expr: EField({ expr: EConst(CString(value))},'atom')},[]):
        value;
      case _:
        Context.error("Application Name must be an atom", Context.currentPos());
        null;
    }
  }

  private static function getClassesToInclude(classPath: String): Array<String> {
    var files: Array<Dynamic> = [];
    var classes: Array<String> = [];
    gatherFilesToCompile(classPath, classPath, files, classes);
    return classes;
  }

  private static function gatherFilesToCompile(path: String, classPath: String, files: Array<Dynamic>, classes: Array<String>): Void {
    if(!FileSystem.exists(path)) {
      return;
    }
    var filesToCompile: Array<String> = FileSystem.readDirectory(path);
    for (script in filesToCompile) {
      var relPath: String = path + '/' + script;
      var fullPath: String = FileSystem.absolutePath(relPath);
      if(FileSystem.isDirectory(fullPath)) {
        gatherFilesToCompile(relPath, classPath, files, classes);
      } else {
        var scriptPath: String = StringTools.replace(relPath, classPath, "");

        var pack: String = StringTools.replace(scriptPath, ".hx", "");
        if(StringTools.startsWith(pack, '/')) {
          pack = pack.substr(1);
        }
        pack = StringTools.replace(pack, "/", ".");
        classes.push(pack);
        files.push({scriptPath: scriptPath.substr(1), fullPath: fullPath});
      }
    }
  }
  #end
}