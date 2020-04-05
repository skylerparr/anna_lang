package util;
import haxe.io.Bytes;
import sys.io.Process;
class Compiler {
  public function new() {
  }

  public static inline function compileProject(): Tuple {
    #if !scriptable
    Sys.setCwd('_build');
    var p: Process = new Process("haxe", ['build.hxml']);
    var stdout = p.stderr;
    var output: Bytes = stdout.readAll();
    var exitCode = p.exitCode(true);
    if (exitCode == 1) {
      trace(output.getString(0, output.length));
    }
    Sys.setCwd('..');
    return Tuple.create([Atom.create('ok'), '${exitCode}']);
    #else
    return Tuple.create([Atom.create('error'), 'not supported']);
    #end
  }
}
