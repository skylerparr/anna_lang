package core;

import minject.Injector;

class ObjectFactory implements ObjectCreator {

  public var injector: Injector;

  public function new() {
  }

  public function createInstance(clazz: Class<Dynamic>, ?constructorArgs: Array<Dynamic>): Dynamic {
    if(constructorArgs == null) {
      constructorArgs = [];
    }
    trace(clazz);
    var retVal = null;
    try {
      trace(injector);
      retVal = injector.getInstance(clazz);
    } catch(e: Dynamic) {
      trace(e);
      retVal = Type.createInstance(clazz, constructorArgs);
      trace(retVal);
      injector.injectInto(retVal);
    }

    if(Std.is(retVal, BaseObject)) {
      trace('init');
      retVal.init();
    }
    trace(retVal);

    return retVal;
  }

  public function disposeInstance(object: BaseObject): Void {
    if(object == null) {
      return;
    }
    object.dispose();
  }
}