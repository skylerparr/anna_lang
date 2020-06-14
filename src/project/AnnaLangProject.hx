package project;

class AnnaLangProject {
  private static inline var OUTPUT_DIR: String = 'out/';
  private static inline var MAIN_SRC_DIR: String = 'src/';
  private static inline var LIB_DIR: String = 'lib/';
  private static inline var APPS_DIR: String = 'apps/';
  private static inline var TESTS_DIR: String = 'test/';

  @:isVar
  public var appRoot(get, null): String;
  @:isVar
  public var application(get, null): Atom;
  @:isVar
  public var autoStart(get, null): String;
  @:isVar
  private var apps(get, null): Array<String>;
  @:isVar
  private var libs(get, null): Array<Atom>;
  @:isVar
  private var haxeLibs(get, null): Array<String>;
  public var srcDir(get, never): String;
  private var testsDir(get, never): String;
  public var projectDir(get, never): String;

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

  public function get_autoStart(): String {
    return autoStart;
  }

  public function get_srcDir(): String {
    return '${projectDir}/${LIB_DIR}';
  }

  public function get_testsDir(): String {
    return '${projectDir}/${TESTS_DIR}';
  }


  public function get_projectDir(): String {
    return '${appRoot}${APPS_DIR}${application.value}';
  }

  public function new(appRoot: String, application: Atom, autoStart: String, apps: Array<String>, libs: Array<Atom>, haxeLibs: Array<String>) {
    this.appRoot = appRoot;
    this.application = application;
    this.autoStart = autoStart;
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

    var hxLibs: Array<String> = ['hscript-plus', 'sepia', 'mockatoo'].concat(this.haxeLibs);

    return new DefaultProjectConfig(nameify(application.value), srcDir, OUTPUT_DIR, projectApps, hxLibs);
  }

  public function getProjectTestsConfig(): ProjectConfig {
    var srcDir: String = testsDir;
    var projectApps: Array<String> = [];
    for(app in apps) {
      projectApps.push('${appRoot}${APPS_DIR}${app}/${LIB_DIR}');
    }
    projectApps.push('${appRoot}${MAIN_SRC_DIR}');
    projectApps.push('${this.srcDir}');

    var hxLibs: Array<String> = ['hscript-plus', 'sepia', 'mockatoo'].concat(this.haxeLibs);

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
