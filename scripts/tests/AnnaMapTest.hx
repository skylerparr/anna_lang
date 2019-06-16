package tests;

import lang.FunctionSpec;
import lang.ModuleSpec;
import lang.CustomTypes;
import lang.CustomTypes.CustomType;
import anna_unit.Assert;

using lang.AtomSupport;
class AnnaMapTest {

//  public static function shouldReturnMapAndNotAnnaMapForToString(): Void {
//    Assert.areEqual('Map', new AnnaMap<String, String>().toString());
//  }
//
//  public static function shouldSetValuesOnMap(): Void {
//    var m: AnnaMap<Atom, String> = new AnnaMap<Atom, String>();
//    m.put('test'.atom(), 'hello');
//    m.put('test2'.atom(), 'world');
//
//    Assert.areEqual(m.toAnnaString(), '%{:test => "hello", :test2 => "world"}');
//  }
//
//  public static function shouldGetValuesOnMap(): Void {
//    var m: AnnaMap<LList<String>, String> = new AnnaMap<LList<String>, String>();
//    var l: LList<String> = CustomTypes.createList("String", ['foo', 'bar', 'cat']);
//    m.put(l, 'hello');
//
//    Assert.areEqual(m.get(CustomTypes.createList("String", ['foo', 'bar', 'cat'])), 'hello');
//  }
//
//  public static function shouldRemoveKeyFromMap(): Void {
//    var m: AnnaMap<Atom, String> = new AnnaMap<Atom, String>();
//    m.put('test'.atom(), 'hello');
//    m.put('test2'.atom(), 'world');
//    m.remove('test'.atom());
//
//    Assert.areEqual(m.toAnnaString(), '%{:test2 => "world"}');
//  }
//
//  public static function shouldReturnNewMapAsHaxeString(): Void {
//    var m: AnnaMap<Atom, Int> = new AnnaMap<Atom, Int>();
//    m.put('foo'.atom(), 2);
//
//    Assert.areEqual(m.toHaxeString(), 'lang.CustomTypes.createMap("Atom", "Int", cast [ AtomSupport.atom("foo") => 2 ])');
//
//    var m: AnnaMap<ModuleSpec, FunctionSpec> = new AnnaMap<ModuleSpec, FunctionSpec>();
//    m.put(ModuleSpec.nil, FunctionSpec.nil);
//
//    Assert.areEqual(m.toHaxeString(), 'lang.CustomTypes.createMap("lang.ModuleSpec", "lang.FunctionSpec", cast [ new ModuleSpec(AtomSupport.atom("nil"), [], AtomSupport.atom("nil"), AtomSupport.atom("nil")) => new lang.FunctionSpec(AtomSupport.atom("nil"), "", [[]], AtomSupport.atom("nil"), []) ])');
//  }

}