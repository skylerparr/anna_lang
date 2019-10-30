package ;

class StaticInit {

  public function new() {
  }

  public static function main(): Void {
    StaticInit.print("hello world");
    new StaticInit();
  }

  public static function print(str): Void {
    python.Lib.print(str);
  }


}