package core;
import haxe.macro.Expr;
class PathSettings {

  public static var applicationBasePath: String = Sys.getCwd();

//  macro public static function applicationPath(): Expr {
//    var cwd = Sys.getCwd();
//
//    return macro {
//      $v{cwd};
//    }
//  }

  public function new() {
  }
}
