package ;

import sys.io.FileOutput;
import sys.io.File;
class Native {

  public static function call(o:Dynamic, funStr:String, args:Array<Dynamic>):Dynamic {
    var fun = Reflect.field(o, funStr);
    return Reflect.callMethod(o, fun, args);
  }

  public static function callStatic(mod:String, funStr:String, args:Array<Dynamic>):Dynamic {
    var clazz = Type.resolveClass(mod);
    return call(clazz, funStr, args);
  }
}
