package core;
class PathSettings {

  public static var applicationBasePath: String = {
    Sys.getCwd();
  }

  public function new() {
  }
}
