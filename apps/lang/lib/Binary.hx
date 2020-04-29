package;

import lang.CustomType;
import haxe.io.Bytes;

@:rtti
class Binary implements CustomType {
  private var bytes: Bytes;
  private var annaString: String;

  public static function create(values: Array<Int>): Binary {
    var bytes = arrayToBytes(values);
    return new Binary(bytes);
  }

  private static function arrayToBytes(ba:Array<Int>):Bytes {
    var bytes:Bytes = Bytes.alloc(ba.length);
    for (i in 0...ba.length) {
      bytes.set(i, ba[i]);
    }
    return bytes;
  }

  public function new(bytes: Bytes) {
    this.bytes = bytes;
  }

  public function getBytes(): Bytes {
    return this.bytes;
  }

  public function toAnnaString(): String {
    if(annaString != null) {
      return annaString;
    }
    var i:Int = 0;
    var arr:Array<String> = [];
    for (i in 0...bytes.length) {
      arr.push(Std.string(bytes.get(i)));
    }

    annaString = '<<' + arr.join(",") + '>>';
    return annaString;
  }
}
