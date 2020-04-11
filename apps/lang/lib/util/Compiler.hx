package util;
import haxe.io.Bytes;
import sys.io.Process;
class Compiler {
  public function new() {
  }

  public static inline function compileProject(project: String): Tuple {
    #if !scriptable
    var oldCWD: String = Sys.getCwd();
    Sys.setCwd('${project}/_build');
    var p: Process = new Process("haxe", ['build.hxml']);
    var stderr = p.stdout;
    var output: Bytes = stderr.readAll();
    var exitCode = p.exitCode(true);
    trace(output.getString(0, output.length));
    Sys.setCwd(oldCWD);
    return Tuple.create([Atom.create('ok'), '${exitCode}']);
    #else
    return Tuple.create([Atom.create('error'), 'not supported']);
    #end
  }
}
