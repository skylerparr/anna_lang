package ;

import lang.CustomType;
import lang.EitherSupport;

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

  public static function hd(list: LList): Any {
    return EitherSupport.getValue((cast list).getHead());
  }

  public static function tl(list: LList): LList {
    return (cast list).getTail();
  }

  public static function length(list: LList): Int {
    return (cast list).length;
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
  
  public function toString(): String {
    return "LList";
  }

  public static function iterator(list: LList) : ListIterator<Any> {
    return (cast list)._iterator();
  }

}

private class ListIterator<T> {
  var head:ListNode<T>;

  public inline function new(head:ListNode<T>) {
    this.head = head;
  }

  public inline function hasNext():Bool {
    return head != null;
  }

  public inline function next():T {
    var val = head.item;
    head = head.next;
    return val;
  }
}

@:generic
class AnnaList<T> extends LList {

  function getHead(): T {
    if(h == null) {
      return null;
    }
    return h.item;
  }

  function getTail(): AnnaList<T> {
    if(tl == null) {
      tl = new AnnaList<T>();
      if(h == null) {
        return null;
      }
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
      _annaString = '{${s}}';
    }
    return _annaString;
  }

  public function _iterator(): ListIterator<T> {
    return new ListIterator<T>(h);
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
