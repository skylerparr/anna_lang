package ;

class Native {

  public static function call(o:Dynamic, funStr:String, args:Array<Dynamic>):Dynamic {
    var fun = Reflect.field(o, funStr);
    return Reflect.callMethod(o, fun, args);
  }

  public static function callStatic(mod:String, funStr:String, args:Array<Dynamic>):Dynamic {
    var clazz = Type.resolveClass(mod);
    if(clazz == null) {
      return null;
    }
    return call(clazz, funStr, args);
  }

  public static function callStaticField(mod:String, field:String):Dynamic {
    var clazz = Type.resolveClass(mod);
    return Reflect.getProperty(clazz, field);
  }
}
