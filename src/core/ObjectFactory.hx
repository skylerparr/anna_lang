package core;

import haxe.ds.ObjectMap;
class ObjectFactory {

  private static var classMap: ObjectMap<Dynamic, String>;

  public function new() {
    classMap = new ObjectMap<Dynamic, String>();
  }

  public function createInstance(clazz:Class<Dynamic>, ?constructorArgs:Array<Dynamic>):Dynamic {
    if(constructorArgs == null) {
      constructorArgs = [];
    }
    var retVal = null;
    var className: String = classMap.get(clazz);
    if(className != null) {
      var clazz = Type.resolveClass(className);
      retVal = Type.createInstance(clazz, []);
    } else {
      retVal = Type.createInstance(clazz, []);
    }

    return retVal;
  }
}