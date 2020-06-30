package util;

import sys.io.*;
import haxe.io.*;
import haxe.zip.*;

class ZipUtil {
  public static inline function getEntries(fileName: String): Tuple {
    var fileInput: FileInput = File.read(fileName, false);
    var entryList: List<Entry> = Reader.readZip(fileInput);
    var entries: Array<Any> = [];
    for(entry in entryList) {
      var compressed: Atom = {
        if(entry.compressed) {
          Atom.create("true");
        } else {
          Atom.create("false");
        }
      }
      var map: MMap = MMap.create({
        [
          Atom.create("file_name"), entry.fileName, 
          Atom.create("file_time"), entry.fileTime,
          Atom.create("file_size"), entry.fileSize,
          Atom.create("data_size"), entry.dataSize,
          Atom.create("data"), entry.data,
          Atom.create("crc32"), entry.crc32,
          Atom.create("compressed"), compressed,
        ];
      });
      entries.push(map);
    }
    return Tuple.create([Atom.create("ok"), LList.create(entries)]);
  }  

  public static inline function getString(entryMap: MMap): Tuple {
    var size: Int = MMap.get(entryMap, Atom.create("data_size"));
    if(size == 0) {
      return Tuple.create([Atom.create("error"), Atom.create("empty_file")]);
    } else {
      var bytes: Bytes = MMap.get(entryMap, Atom.create("data"));
      var dataString = bytes.getString(0, size);
      return Tuple.create([Atom.create("ok"), dataString]);
    }
  }
}
