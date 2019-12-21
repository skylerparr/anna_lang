package util;
import lang.EitherSupport;
class Template {
  public function new() {

  }

  public static function execute(str: String, params: MMap): String {
    var template: haxe.Template = new haxe.Template(str);
    var keys: LList = MMap.keys(params);
    var args: Dynamic = {};
    for(key in LList.iterator(keys)) {
      var value: Dynamic = EitherSupport.getValue(MMap.get(params, key));
      var keyStr: String = Atom.to_s(EitherSupport.getValue(key));
      Reflect.setField(args, keyStr, value);
    }
    return template.execute(args);
  }
}
