package ;

import lang.AmbiguousFunctionException;
import lang.CustomType;
import lang.EitherSupport;
import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import org.hxbert.BERT.ErlangValue;
import org.hxbert.BERT;
using lang.AtomSupport;
@:rtti
class Tuple implements CustomType {

  public static function elem(t: Tuple, index: Int): Any {
    return cast(t, TupleInstance).elem(index);
  }
  
  public static function create(val: Array<Any>): Tuple {
    return new TupleInstance(val);
  }

  public static function array(tuple: Tuple): Array<Any> {
    return cast(tuple, TupleInstance).asArray();
  }

  public static function push(tuple: Tuple, value: Any): Tuple {
    return cast(tuple, TupleInstance).push(value);
  }

  public static function addElemAt(tuple: Tuple, value: Any, index: Int): Tuple {
    return cast(tuple, TupleInstance).addElementAt(value, index);
  }

  public static function removeElemAt(tuple: Tuple, index: Int): Tuple {
    return cast(tuple, TupleInstance).removeElementAt(index);
  }

  public static function length(tuple: Tuple): Int {
    return cast(tuple, TupleInstance).length();
  }

  public function toAnnaString():String {
    return '';
  }

  public function termToBinary(): Binary {
    return null;
  }

  public function asBert(): Dynamic {
    return null;
  }

  public static function fromBert(value: ErlangValue): Tuple {
    var arr: Array<Any> = [];
    var values: Array<Dynamic> = cast value.value;
    for(v in values) {
      arr.push(Anna.bertToTerm(v));
    }
    return create(arr);
  }
}

@:generic
class TupleInstance extends Tuple implements CustomType {
  private var values: Array<Any>;
  private var __annaString: String;

  public inline function new(values: Array<Any>) {
    this.values = values;
  }

  public function elem(index:Int):Any {
    return values[index];
  }

  public function length(): Int {
    return values.length;
  }

  public function asArray(): Array<Any> {
    return values;
  }

  public function push(value:Any):Tuple {
    var newArray = values.copy();
    newArray.push(value);
    return new TupleInstance(newArray);
  }

  public function addElementAt(value:Any, index:Int):Tuple {
    var newArray = values.copy();
    newArray.insert(index, value);
    return new TupleInstance(newArray);
  }

  public function removeElementAt(index:Int):Tuple {
    var newArray: Array<Any> = values.copy();
    var counter = 0;
    for(a in newArray) {
      if(counter++ == index) {
        newArray.remove(a);
        break;
      }
    }
    return new TupleInstance(newArray);
  }

  override public function toAnnaString(): String {
    if(__annaString == null) {
      var stringFrags: Array<String> = [];
      var vars: Array<Any> = asArray();
      for(v in vars) {
        stringFrags.push(Anna.toAnnaString(v));
      }
      __annaString = '[${stringFrags.join(', ')}]';
    }
    return __annaString;
  }

  public function toBytes(): Bytes {
    var vars: Array<Any> = asArray();
    var retVal: BytesBuffer = new BytesBuffer();
    for(v in vars) {
      var bin: Binary = Anna.termToBinary(v);
      retVal.add(bin.getBytes());
    } 
    return retVal.getBytes();
  }

  override public function asBert(): Dynamic {
    var bertFrags: Array<Dynamic> = [];
    var vars: Array<Any> = asArray();
    for(v in vars) {
      var frag = Anna.termToBert(v);
      bertFrags.push(frag);
    }
    return BERT.tuple(bertFrags);
  }
}
