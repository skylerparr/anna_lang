package util;

import haxe.xml.*;

class XMLUtil {

  public static inline function parse(string: String): Tuple {
    var x = Xml.parse(string);
    var retVal: LList = LList.create([]);
    iterateChildren(x, retVal);
    return Tuple.create([Atom.create("ok"), retVal]);
  }

  private static function iterateChildren(x: Xml, retVal: LList): Void {
    for(e in x.elements()) {
      var mmap: MMap = MMap.create([]);
      mmap = MMap.put(mmap, "__node_name__", e.nodeName);
      for(a in e.attributes()) {
        mmap = MMap.put(mmap, a, e.get(a));
      }
      var children: LList = LList.create([]);
      iterateChildren(e, children);
      mmap = MMap.put(mmap, "__children__", children);
      if(e.firstChild() != null) {
        var nodeValue = e.firstChild().nodeValue;
        if(nodeValue != null && StringTools.trim(nodeValue) != "") {
          mmap = MMap.put(mmap, "__node_value__", nodeValue);
        }
      }
      retVal = LList.add(retVal, mmap);
    }
  }

  public static inline function stringify(mmap: MMap): Tuple {
    return Tuple.create([Atom.create("error"), Atom.create("unimplemented")]);
  }

}
