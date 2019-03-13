package;

import lang.CustomTypes.CustomType;

using StringTools;

@:generic
class AnnaList<T> implements CustomType {

  public var head(get, never): T;
  public var tail(get, never): AnnaList<T>;

  function get_head(): T {
    return h.item;
  }

  function get_tail(): AnnaList<T> {
    if(tl == null) {
      tl = new AnnaList(q.item);
    }
    return tl;
  }

  public var length(default, null): Int;

  public var h: ListNode<T>;
  public var q: ListNode<T>;

  public var tl: AnnaList<T>;
  
  public var type: String;

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

  public function push(item: T): AnnaList<T> {
    var x = ListNode.create(item, h);
    h = x;
    if(q == null) {
      q = x;
    }
    length++;
    return this;
  }

  public function toString(): String {
    return 'List';
  }
  
  public function add(item: T) {
    var x = ListNode.create(item, null);
    if(h == null) {
      h = x;
    } else {
      q.next = x;
    }
    q = x;
    length++;
  }

  public function remove(item: T): Bool {
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
        return true;
      }
      prev = l;
      l = l.next;
    }
    return false;
  }

  public function toAnnaString(): String {
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
    return '[${s}]';
  }

  public function toHaxeString(): String {
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

  public function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String {
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
