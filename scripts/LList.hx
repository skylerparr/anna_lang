package;

import lang.CustomTypes.CustomType;

using StringTools;

class LList implements CustomType {
  public static function create(vals: Array<Any>): LList {
    var retVal = new AnnaList<Any>();
    for(v in vals) {
      retVal._add(v);
    }
    return retVal;
  }

  public static function push(list: LList, value: Any): LList {
    return (cast list)._push(value);
  }

  public static function add(list: LList, value: Any): LList {
    return (cast list)._add(value);
  }

  public static function hd(list: LList): LList {
    return (cast list).getHead();
  }

  public static function tl(list: LList): LList {
    return (cast list).getTail();
  }

  public static function remove(list: LList, item: Any): LList {
    return (cast list)._remove(item);
  }

  public var head(get, never): Any;
  public var tail(get, never): Any;

  function get_head(): Any {
    return (cast this).getHead();
  }

  function get_tail(): Any {
    return (cast this).getTail();
  }

  public function toAnnaString(): String {
    return '';
  }

  public function toHaxeString(): String {
    return '';
  }

  public function toPattern(patternArgs: Array<KeyValue<String,String>> = null): String {
    return '';
  }

  public function toString(): String {
    return "LList";
  }

}

@:generic
class AnnaList<T> extends LList {

  function getHead(): T {
    return h.item;
  }

  function getTail(): AnnaList<T> {
    if(tl == null) {
      tl = new AnnaList<T>();
      var t = h.next;
      while(t != null) {
        tl._add(t.item);
        t = t.next;
      }
    }
    return tl;
  }

  public var length(default, null): Int;

  public var h: ListNode<T>;
  public var q: ListNode<T>;

  public var tl: AnnaList<T>;
  
  public var type: String;

  private var _annaString: String = null;

  public function new(h: T = null) {
    length = 0;
    if(h != null) {
      this.h = ListNode.create(h, null);
    }
    switch(Type.typeof(this)) {
      case TClass(clazz):
        var classString: String = '${clazz}';
        type = classString.replace('AnnaList_', '');
        type = type.replace('_', '.');
      case _:
        
    }
  }

  public function _push(item: T): AnnaList<T> {
    var x = ListNode.create(item, h);
    h = x;
    if(q == null) {
      q = x;
    }
    length++;
    tl = null;
    _annaString = null;
    return this;
  }

  override public function toString(): String {
    return 'AnnaList';
  }
  
  public function _add(item: T): AnnaList<T> {
    var x = ListNode.create(item, null);
    if(h == null) {
      h = x;
    } else {
      q.next = x;
    }
    q = x;
    length++;
    tl = null;
    _annaString = null;
    return this;
  }

  public function _remove(item: T): LList {
    var prev: ListNode<T> = null;
    var l = h;
    while(l != null) {
      if(Anna.toAnnaString(l.item) == Anna.toAnnaString(item)) {
        if(prev == null) {
          h = l.next;
        } else {
          prev.next = l.next;
        }
        if(q == l) {
          q = prev;
        }
        length--;
        tl = null;
        _annaString = null;
        return this;
      }
      prev = l;
      l = l.next;
    }
    return this;
  }

  override public function toAnnaString(): String {
    if(_annaString == null) {
      var s = new StringBuf();
      var first = true;
      var l = h;
      while(l != null) {
        if(first) {
          first = false;
        } else {
          s.add(', ');
        }
        s.add(Anna.toAnnaString(l.item));
        l = l.next;
      }
      _annaString = '[${s}]';
    }
    return _annaString;
  }

  override public function toHaxeString(): String {
    var s = new StringBuf();
    var first = true;
    var l = h;
    while(l != null) {
      if(first) {
        first = false;
      } else {
        s.add(', ');
      }
      s.add(Anna.toHaxeString(l.item));
      l = l.next;
    }
    return 'lang.CustomTypes.createList("${type}", [${s}])';
  }

  override public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
    if(patternArgs == null) {
      patternArgs = [];
    }
    var retVal: Array<String> = [];
    for(pattern in patternArgs) {
      retVal.push('${pattern.key}: ${pattern.value}');
    }
    return '{${retVal.join(', ')}}';
  }

}

#if neko
private extern class ListNode<T> extends neko.NativeArray<Dynamic> {
	var item(get,set):T;
	var next(get,set):ListNode<T>;
	private inline function get_item():T return this[0];
	private inline function set_item(v:T):T return this[0] = v;
	private inline function get_next():ListNode<T> return this[1];
	private inline function set_next(v:ListNode<T>):ListNode<T> return this[1] = v;
	inline static function create<T>(item:T, next:ListNode<T>):ListNode<T> {
		return untyped __dollar__array(item, next);
	}
}
#else
private class ListNode<T> {
  public var item: T;
  public var next: ListNode<T>;

  public function new(item: T, next: ListNode<T>) {
    this.item = item;
    this.next = next;
  }

  @:extern public inline static function create<T>(item: T, next: ListNode<T>): ListNode<T> {
    return new ListNode(item, next);
  }
}
#end