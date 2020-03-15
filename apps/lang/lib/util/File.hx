package util;
import sys.FileSystem;
class File {
  public static inline function removeAll(path: String): Tuple {
    try {
      var path: String = FileSystem.fullPath(path) + '/';
      if(FileSystem.exists(path)) {
        var toDelete: Array<String> = FileSystem.readDirectory(path);
        if(toDelete.length > 0) {
          for(file in toDelete) {
            var path: String = FileSystem.fullPath(path + file);
            if(FileSystem.isDirectory(path)) {
              removeAll(path);
              FileSystem.deleteDirectory(path);
            } else {
              FileSystem.deleteFile(path);
            }
          }
        } else {
          FileSystem.deleteDirectory(path);
        }
      }
      FileSystem.deleteDirectory(path);
      return Tuple.create([Atom.create('ok'), path]);
    } catch(e: Dynamic) {
      return Tuple.create([Atom.create('error'), '${e}']);
    }
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

  public static function getContent(path:String):String {
    if(FileSystem.exists(path)) {
      return File.getContent(path);
    }
    return 'FIXME: File does not exist';
  }

  public static function saveContent(path:String, content: String):Tuple {
    trace("TODO: check to see if necessary directories exist");
    return File.saveContent(path, content);
  }

  public static function copy(src:String, dest:String):Tuple {
    File.copy(src, dest);
    return Tuple.create([Atom.create('ok'), src, dest]);
  }
}
