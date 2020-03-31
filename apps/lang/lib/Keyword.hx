package ;
import lang.CustomType;
using lang.AtomSupport;
@:rtti
class Keyword implements CustomType {
  private var __annaString: String;
  private var data: Array<Tuple>;
  private var uniqueKeys: Map<Atom, Int>;

  public static function create(keyword:Array<Array<Any>>):Keyword {
    return new Keyword(keyword);
  }

  public function new(kw:Array<Array<Any>>) {
    uniqueKeys = new Map<Atom, Int>();
    data = [];
    for(value in kw) {
      var key: Atom = value[0].atom();
      data.push(Tuple.create([key, value[1]]));
      var count: Null<Int> = 0;
      if(uniqueKeys.exists(key)) {
        count = uniqueKeys.get(key);
      }
      uniqueKeys.set(key, count + 1);
    }
  }

  public function asArray(): Array<Tuple> {
    return data;
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
        var uniqueKeys: Map<Atom, Int> = keyword.uniqueKeys;
        var count: Null<Int> = uniqueKeys.get(field);
        count--;
        if(count == 0) {
          uniqueKeys.remove(field);
        } else {
          uniqueKeys.set(field, count);
        }
        break;
      }
    }
    return keyword;
  }

  public static function add(keyword:Keyword, field:Atom, value:Dynamic):Keyword {
    keyword.data.push(Tuple.create([field, value]));
    var uniqueKeys: Map<Atom, Int> = keyword.uniqueKeys;
    var count: Null<Int> = uniqueKeys.get(field);
    if(count == null) {
      count = 0;
    }
    count++;
    uniqueKeys.set(field, count);
    return keyword;
  }

  public static function hasKey(keyword:Keyword, field:Atom):Atom {
    if(keyword.uniqueKeys.get(field) == null) {
      return Atom.create('false');
    } else {
      return Atom.create('true');
    }
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
