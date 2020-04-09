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

  public static function remove(file:String):Tuple {
    FileSystem.deleteFile(file);
    return Tuple.create([Atom.create('ok'), file]);
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

  public static inline function getContent(path:String):Tuple {
    if(FileSystem.exists(path)) {
      return Tuple.create([Atom.create('ok'), sys.io.File.getContent(path)]);
    } else {
      return Tuple.create([Atom.create('error'), 'File does not exist']);
    }
  }

  public static inline function saveContent(path:String, content: String):Tuple {
    trace("TODO: check to see if necessary directories exist");
    sys.io.File.saveContent(path, content);
    return Tuple.create([Atom.create('ok'), path]);
  }

  public static inline function copy(src:String, dest:String):Tuple {
    sys.io.File.copy(src, dest);
    return Tuple.create([Atom.create('ok'), src, dest]);
  }

  public static inline function exists(fileName:String):Atom {
    if(FileSystem.exists(fileName)) {
      return Atom.create('true');
    } else {
      return Atom.create('false');
    }
  }

  public static inline function append(fileName: String, data: String):Tuple {
    var output: haxe.io.Output = sys.io.File.append(fileName);
    output.writeString(data);
    output.close();
    return Tuple.create([Atom.create('ok'), fileName]);
  }
}
