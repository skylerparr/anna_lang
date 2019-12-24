package util;
import sys.FileSystem;
class File {
  public static inline function removeAll(path: String): Tuple {
    if(FileSystem.exists(path)) {
      var toDelete: Array<String> = FileSystem.readDirectory(path);
      for(file in toDelete) {
        if(FileSystem.isDirectory(file)) {
          removeAll(file);
          FileSystem.deleteDirectory(file);
        } else {
          FileSystem.deleteFile('${path}${file}');
        }
      }
    }
    return Tuple.create([Atom.create('ok'), path]);
  }
}
