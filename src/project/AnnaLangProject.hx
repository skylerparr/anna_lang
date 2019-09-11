package project;

class AnnaLangProject {
  private static inline var OUTPUT_DIR: String = 'out/';
  private static inline var MAIN_SRC_DIR: String = 'src/';
  private static inline var LIB_DIR: String = 'lib/';
  private static inline var APPS_DIR: String = 'apps/';
  private static inline var TESTS_DIR: String = 'test/';

  @:isVar
  private var appRoot(get, null): String;
  @:isVar
  private var application(get, null): Atom;
  @:isVar
  private var apps(get, null): Array<String>;
  @:isVar
  private var libs(get, null): Array<Atom>;
  @:isVar
  private var haxeLibs(get, null): Array<String>;
  private var srcDir(get, never): String;

  function get_appRoot(): String {
    return appRoot;
  }

  public function get_application(): Atom {
    return application;
  }

  public function get_apps(): Array<String> {
    return apps;
  }

  public function get_haxeLibs(): Array<String> {
    return haxeLibs;
  }

  public function get_libs(): Array<Atom> {
    return libs;
  }

  public function get_srcDir(): String {
    return '${appRoot}${APPS_DIR}${application.value}/${LIB_DIR}';
  }

  public function new(appRoot: String, application: Atom, apps: Array<String>, libs: Array<Atom>, haxeLibs: Array<String>) {
    this.appRoot = appRoot;
    this.application = application;
    this.apps = apps;
    this.libs = libs;
    this.haxeLibs = haxeLibs;
  }

  public function getProjectConfig(): ProjectConfig {
    var srcDir: String = srcDir;
    var projectApps: Array<String> = [];
    for(app in apps) {
      projectApps.push('${appRoot}${APPS_DIR}${app}/${LIB_DIR}');
    }
    projectApps.push('${appRoot}${MAIN_SRC_DIR}');

    var hxLibs: Array<String> = ['hscript-plus', 'sepia', 'mockatoo'];

    return new DefaultProjectConfig(nameify(application.value), srcDir, OUTPUT_DIR, projectApps, hxLibs);
  }

  private static inline function nameify(snake_name: String): String {
    var retVal: String = "";
    var capitalizeNext: Bool = true;
    for(i in 0...snake_name.length) {
      var char: String = snake_name.charAt(i);
      if(capitalizeNext) {
        retVal += char.toUpperCase();
        capitalizeNext = false;
      } else if(char == '_') {
        capitalizeNext = true;
      } else {
        retVal += char;
      }
    }
    return retVal;
  }
}