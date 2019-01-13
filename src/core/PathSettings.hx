package core;
import haxe.macro.Expr;
class PathSettings {

  public static var applicationBasePath: String = applicationPath();

  macro public static function applicationPath(): Expr {
    var cwd = Sys.getCwd();

    return macro {
      $v{cwd};
    }
  }

  public function new() {
  }
}
