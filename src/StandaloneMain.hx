import haxe.rtti.Rtti;
import cpp.NativeProcess;
import sys.io.File;
import sys.FileSystem;
import project.DefaultProjectConfig;
import project.ProjectConfig;
import hscript.plus.ParserPlus;
import lang.HashTableAtoms;
import haxe.ds.ObjectMap;
import haxe.Timer;
import haxe.CallStack;
import haxe.Constraints.IMap;
import haxe.macro.Printer;
import state.GlobalStore;
import core.PathSettings;
import hscript.Macro;
import hscript.Interp;
import hscript.Parser;
import org.hxbert.BERT;
#if scriptable
import cpp.vm.Thread;
#end

using lang.AtomSupport;
@:rtti
class StandaloneMain {
  #if scriptable
  private static var mainThread: Thread;
  #end
  private static var ready: Bool = false;

  public static var compilerCompleteCallbacks: Array<Void->Void> = [];

  private static var project: ProjectConfig;

  public static function main() {
    BERT;
    BERT.encode(1);
    Native;
    EitherEnums;
    HashTableAtoms;
    var regex = ~/\s/g;
    regex.map("", function(e) {
      regex.matched(0);
      return "";
    });
    regex.matchSub("", 0, 1);
    Rtti.hasRtti(StandaloneMain);
    Rtti.getRtti(StandaloneMain);
    FileSystem.createDirectory;
    File.copy;
    FileSystem.deleteDirectory;
    FileSystem.deleteFile;
    CallStack.exceptionStack();
    CallStack.callStack();
    Sys.setCwd('.');
    Sys.getCwd();
    Sys.environment();
    haxe.crypto.Sha256.encode('');
    var t = new haxe.Template("");
    t.execute({});
    var m: IMap<String, String> = new Map<String, String>();
    m.keys();
    m.remove('');
    for(v in m) {}
    m.toString();
    var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    for(v in map) {}
    for(k in map.keys()) {}
    Timer.stamp();
    new Date(2018, 1, 1, 0, 0, 0).getTime();
    new Printer().printExpr(macro 'foo');
    GlobalStore.start();
    new StandaloneMain();
  }

  public function new() {
    var basePath: String = PathSettings.applicationBasePath;
    project = new DefaultProjectConfig('AnnaLang', '${basePath}scripts', '${basePath}out/',
      ['${basePath}src/', '${basePath}apps/anna_unit/lib', '${basePath}apps/lang/lib'], ['hscript-plus', 'sepia', 'hxbert']);

    #if scriptable
    mainThread = Thread.current();
    Thread.create(function() {
      var loaded: Bool = false;
      var onComplete = function(files: Array<String>) {
        if(!loaded) {
          var files = Runtime.loadAll(project);
          mainThread.sendMessage(files);
          loaded = true;
        } else {
          mainThread.sendMessage(files);
        }
      }
      project.subscribeAfterCompileCallback(onComplete);
      Runtime.compileProject(project);
    });

    pollChanges();
    #else
    #if dev_anna
    DevelopmentRunner.start(project);
    #else
    StandaloneRunner.start(project);
    #end
    #end
  }

  #if scriptable
  private inline function pollChanges(): Void {
    while(true) {
      var files: Array<String> = Thread.readMessage(true);

      if(files != null && files.length > 0) {
        var clazz: Class<Dynamic> = Type.resolveClass("DevelopmentRunner");
        if(clazz != null) {
          var fields: Array<String> = Type.getClassFields(clazz);
          for(f in fields) {
            if(f == "start") {
              continue;
            }
          }
          if(!ready) {
            var fun = Reflect.field(clazz, "start");
            fun(project);
          }
          ready = true;
        }
        for(cb in compilerCompleteCallbacks) {
          cb();
        }
      }
    }
  }
  #end

}
