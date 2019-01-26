package lang;

class ArraySupport {
  public static inline function any(array: Array<Dynamic>, value: Dynamic): Bool {
    var retVal: Bool = false;
    for(a in array) {
      if(a == value) {
        retVal = true;
        break;
      }
    }
    return retVal;
  }
}