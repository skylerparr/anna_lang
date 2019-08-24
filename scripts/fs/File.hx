package fs;

class File {
  public static function read(fileName: String): String {
    var data: String = sys.io.File.getContent('./apps/anna/anna.anna');
    return data;
  }
}