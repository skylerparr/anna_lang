package util;
import sys.FileSystem;
class File {
  public static inline function removeAll(path: String): Tuple {
    if(FileSystem.exists(path)) {
      var toDelete: Array<String> = FileSystem.readDirectory(path);
      if(toDelete.length > 0) {
        for(file in toDelete) {
          var path: String = FileSystem.fullPath(path + file);
          if(FileSystem.isDirectory(path)) {
            removeAll(path + '/');
            FileSystem.deleteDirectory(path);
          } else {
            FileSystem.deleteFile(path);
          }
        }
      } else {
        FileSystem.deleteDirectory(path);
      }
    }
    return Tuple.create([Atom.create('ok'), path]);
  }

  public static inline function readDirectory(path:String):LList {
    var files = FileSystem.readDirectory(path);
    var retVal: LList = LList.create([]);
    for(file in files) {
      retVal = LList.add(retVal, file);
    }
    return retVal;
  }

  public static inline function isDirectory(path:String):Atom {
    var result = FileSystem.isDirectory(path);
    if(result) {
      return Atom.create('true');
    } else {
      return Atom.create('false');
    }
  }
}
