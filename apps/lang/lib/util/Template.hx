package util;
import lang.EitherSupport;
class Template {
  public function new() {

  }

  public static function execute(str: String, params: MMap): Tuple {
    if(params == null) {
      return Tuple.create([Atom.create('error'), 'params was nil']);
    }
    try {
      var template: haxe.Template = new haxe.Template(str);
      var args: Dynamic = DSUtil.mmapToDynamic(params);
      var output = template.execute(args);
      return Tuple.create([Atom.create('ok'), output]);
    } catch(e: Dynamic) {
      return Tuple.create([Atom.create('error'), '${e}']);
    }
  }
}
