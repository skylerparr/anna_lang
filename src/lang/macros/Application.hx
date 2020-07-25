package lang.macros;

import project.AnnaLangProject;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
class Application {
  private static inline var APP_DIR: String = 'apps/';
  private static inline var CONFIG_FILE: String = 'app_config.json';

  public static function getProjectConfig(appAtomName: String): AnnaLangProject {
    var appName: String = appAtomName;
    var config: Dynamic = fetchAppConfigByName(appName);

    var appNameExpr: String = appName;
    var autoStart: String = config.autoStart;
    var configApps: Array<String> = cast config.apps;
    var apps: Array<String> = [];
    for(app in configApps) {
      apps.push(app);
    }
    var appsExpr: Array<String> = apps;
    var haxelibsStr: String = '';
    var libs: Array<String> = ["hscript-plus", "sepia"];
    var haxelibs: Array<Dynamic> = cast(config.haxelibs, Array<Dynamic>);
    for(lib in haxelibs) {
      libs.push(lib);
    }
    var appRoot: String = core.PathSettings.applicationBasePath;

    var retVal = new project.AnnaLangProject(appRoot, Atom.create(appNameExpr), autoStart, appsExpr, [], libs);
    return retVal;
  }

  private static inline var ANNA_HOME: String = 'ANNA_HOME';

  public static function annaLangHome(): String {
    var annaLangHome: String = Sys.environment().get(ANNA_HOME);
    if(annaLangHome == null) {
      annaLangHome = '';
    }
    return annaLangHome;
  }

  private static function appDir(appName: String): String {
    return '${APP_DIR}${appName}';
  }

  private static function fetchAppConfigByName(appName: String): Dynamic {
    var strConfig: String = File.getContent('${appDir(appName)}/${CONFIG_FILE}');
    return Json.parse(strConfig);
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
}
