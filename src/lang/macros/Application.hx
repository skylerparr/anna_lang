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
    var configApps: Array<String> = cast config.apps;
    var apps: Array<String> = [];
    for(app in configApps) {
      apps.push('"${app}"');
    }
    var appsExpr: Expr = Macros.haxeToExpr('[${apps.join(",")}]');
    return macro {
      var appRoot: String = Native.callStaticField("core.PathSettings", "applicationBasePath");
      new project.AnnaLangProject(appRoot, $e{appNameExpr}, $e{appsExpr}, [], []);
    }
  }

  #if macro
//  private static function getAnnaLangProjectExpr(appName: String): Expr {
//    var config: Dynamic = fetchAppConfigByName(appName);
//    var appNameExpr: Expr = Macros.haxeToExpr('"${appName}".atom()');
//    var apps: Array<Expr> = [];
//    for(app in config.apps) {
//
//    }
////    var appsExpr: Expr =
//    return macro {
//      new project.AnnaLangProject(appRoot, $e{appNameExpr}, [], [], []);
//    }
//  }

  private static function fetchAppConfigByName(appName: String): Dynamic {
    var strConfig: String = File.getContent('${APP_DIR}${appName}/${CONFIG_FILE}');
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
  #end

  macro public static function defineApplication(applicationName: Expr, srcPath: Expr, outputPath: Expr, classPaths: Expr, libsPaths: Expr): Expr {
    #if cppia
      return macro {
        var appRoot: String = Native.callStaticField("core.PathSettings", "applicationBasePath");
        var applicationName: String = $e{applicationName};
        var srcPath: String = $e{srcPath};
        var outputPath: String = $e{outputPath};
        var libsPaths: Array<String> = $e{libsPaths};
        var classPaths: Array<String> = $e{classPaths};
        for(i in 0...classPaths.length) {
          classPaths[i] = appRoot + classPaths[i];
        }
        new DefaultProjectConfig(applicationName, appRoot + srcPath, outputPath, classPaths, libsPaths);
      }
    #else
    var application: Expr = null;
    var appName: String = "";
    var classPath: String = "";
    switch(applicationName.expr) {
      case (EConst(CString(app))):
        application = Macros.haxeToExpr(app);
        appName = app;
      case _:
        Context.error("ApplicationName must be a string", Context.currentPos());
    }
    switch(srcPath.expr) {
      case (EConst(CString(path))):
        classPath = path + "/";
      case _:
        Context.error("ApplicationName must be a string", Context.currentPos());
    }
//    generate(classPath, appName);
    return macro {
      var appRoot: String = Native.callStaticField("core.PathSettings", "applicationBasePath");
      var applicationName: String = $e{applicationName};
      var srcPath: String = $e{srcPath};
      var outputPath: String = $e{outputPath};
      var libsPaths: Array<String> = $e{libsPaths};
      var classPaths: Array<String> = $e{classPaths};
      for(i in 0...classPaths.length) {
        classPaths[i] = appRoot + classPaths[i];
      }
      new project.DefaultProjectConfig(applicationName, appRoot + srcPath, outputPath, classPaths, libsPaths);
    }
    #end
  }

  #if macro
  private static function generate(classPath: String, applicationName: String): Void {
    var files: Array<Dynamic> = [];
    var classes: Array<String> = [];
    gatherFilesToCompile(classPath, classPath, files, classes);
    generateApplicationFile(classPath, applicationName, files);
  }

  private static function generateApplicationFile(classPath: String, applicationName: String, files: Array<Dynamic>): Void {
    var classes: Array<Dynamic> = [];
    for(file in files) {
      var filename: String = StringTools.replace(file.scriptPath, ".hx", "");
      var className: String = StringTools.replace(filename, "/", ".");
      classes.push({className: className});
    }
    var typeDef: TypeDefinition = MacroTools.createClass(applicationName);

    var field: Field = MacroTools.buildPublicFunction("main", [], MacroTools.buildType("Void"));
    var classNames: Array<Expr> = classes.map(function(c) { return Macros.haxeToExpr('${c.className};'); });

    var body: Expr = MacroTools.buildBlock(classNames);
    field = MacroTools.assignFunBody(field, body);
    MacroTools.addFieldToClass(typeDef, field);

    Context.defineType(typeDef);
    MacroLogger.log(typeDef, 'typeDef');
  }

  private static function gatherFilesToCompile(path: String, classPath: String, files: Array<Dynamic>, classes: Array<String>): Void {
    var filesToCompile: Array<String> = FileSystem.readDirectory(path);
    for (script in filesToCompile) {
      var relPath: String = path + '/' + script;
      var fullPath: String = FileSystem.absolutePath(relPath);
      if(FileSystem.isDirectory(fullPath)) {
        gatherFilesToCompile(relPath, classPath, files, classes);
      } else {
        var scriptPath: String = StringTools.replace(relPath, classPath, "");

        var pack: String = StringTools.replace(scriptPath, ".hx", "");
        pack = StringTools.replace(pack, "/", ".");
        classes.push(pack);
        files.push({scriptPath: scriptPath.substr(1), fullPath: fullPath});
      }
    }
  }
  #end
}