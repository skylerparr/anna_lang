package core;

import minject.Injector;
class InjectionSettings {

  public function new() {
    var objectFactory: ObjectFactory = new ObjectFactory();
    objectFactory.injector = new Injector();
    objectFactory.injector.mapValue(ObjectCreator, objectFactory);
  }

}