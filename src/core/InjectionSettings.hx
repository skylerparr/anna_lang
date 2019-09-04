package core;

import minject.Injector;
class InjectionSettings {
  public var injector: Injector = new Injector();

  public function new() {
    ObjectFactory.injector = injector;

    var objectFactory: ObjectFactory = new ObjectFactory();
    injector.mapValue(ObjectCreator, objectFactory);
  }

}