package ;
import lang.CustomType;
using lang.AtomSupport;
class Keyword implements CustomType {
  public var variables: Map<String,String>;
  private var __annaString: String;
  private var data: Array<Tuple>;

  public static function create(keyword:Array<Array<Any>>):Keyword {
    return new Keyword(keyword);
  }

  public function new(kw:Array<Array<Any>>) {
    data = [];
    for(value in kw) {
      data.push(Tuple.create([value[0].atom(), value[1]]));
    }
  }

  public static function get(keyword:Keyword, field:Atom):Dynamic {
    for(value in keyword.data) {
      if(Tuple.elem(value, 0) == field) {
        return Tuple.elem(value, 1);
      }
    }
    return null;
  }

  public static function getAll(keyword:Keyword, field:Atom):Keyword {
    var found: Array<Array<Any>> = [];
    for(value in keyword.data) {
      var key: Atom = Tuple.elem(value, 0);
      if(key == field) {
        found.push([Atom.to_s(field), Tuple.elem(value, 1)]);
      }
    }
    return create(found);
  }

  public static function keys(keyword:Keyword):LList {
    var retVal: Array<Any> = [];
    for(value in keyword.data) {
      var key: Atom = Tuple.elem(value, 0);
      retVal.push(key);
    }
    return LList.create(retVal);
  }

  public static function remove(keyword:Keyword, field:Atom):Keyword {
    for(value in keyword.data) {
      if(Tuple.elem(value, 0) == field) {
        keyword.data.remove(value);
        break;
      }
    }
    return keyword;
  }

  public static function add(keyword:Keyword, field:Atom, value:Dynamic):Keyword {
    keyword.data.push(Tuple.create([field, value]));
    return keyword;
  }

  public function toAnnaString(): String {
    if(__annaString == null) {
      var stringFrags: Array<String> = [];
      for(value in data) {
        var field: Atom = Tuple.elem(value, 0);
        var v: Dynamic = Tuple.elem(value, 1);
        stringFrags.push('${Atom.to_s(field)}: ${Anna.toAnnaString(v)}');
      }
      __annaString = '{${stringFrags.join(', ')}}';
    }
    return __annaString;
  }
}
