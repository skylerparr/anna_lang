import project.DefaultProjectConfig;
import project.ProjectConfig;
import core.InjectionSettings;
import hscript.plus.ParserPlus;
import lang.HashTableAtoms;
import hx.strings.Strings;
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
import cpp.vm.Thread;
import ihx.HScriptEval;
import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;
class Main {
  public static var parser: Parser = new ParserPlus();
  public static var interp: Interp;         

  private static var mainThread: Thread;
  private static var ready: Bool = false;

  public static var compilerCompleteCallbacks: Array<Void->Void> = [];

  private static var project: ProjectConfig;

  public static function main() {
    Native;
    Random;
    EitherEnums;
    HashTableAtoms;
    CallStack.exceptionStack();
    CallStack.callStack();
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
    Strings.charCodeAt8("foo", 0);
    GlobalStore.start();
    new InjectionSettings();
    new Main();
  }

  public function new() {
    var basePath: String = PathSettings.applicationBasePath;
    project = new DefaultProjectConfig('AnnaLang', '${basePath}scripts', '${basePath}out/',
      ['${basePath}src/', '${basePath}apps/anna_unit/lib', '${basePath}apps/lang/lib'], ['hscript-plus', 'mockatoo', 'minject', 'sepia']);
    parser.allowMetadata = true;
    parser.allowTypes = true;
    interp = HScriptEval.interp;
    var variables = interp.variables;
    variables.set("rc", function() {
      Runtime.compileProject(project);
    });
    variables.set("clean", function() {
      Runtime.clean(project);
    });
    variables.set("s", function(o: Dynamic): Bool {
      o.parser = parser;
      o.interp = interp;
      return true;
    });
    variables.set("hxeval", function(string: String): Dynamic {
      return hxeval(string);
    });
    variables.set('interp', interp);
    variables.set("macro", function(string: String): Dynamic {
      var ast = parser.parseString(string);
      var pos = { max: 12, min: 0, file: null };
      return new Macro(pos).convert(ast);
    });
    variables.set("ast", function(string: String): Dynamic {
      return parser.parseString(string);
    });
    variables.set("Main", Main);
    variables.set("fields", function(o: Dynamic): Dynamic {
      return Reflect.fields(o);
    });
    mainThread = Thread.current();
    Thread.create(function() {
      var loaded: Bool = false;
      var onComplete = function(files: Array<String>) {
        if(!loaded) {
          var files = Runtime.loadAll(project);
          mainThread.sendMessage(files);
          loaded = true;
          Runtime.start();
        } else {
          mainThread.sendMessage(files);
        }
      }
      project.subscribeAfterCompileCallback(onComplete);
      Runtime.compileProject(project);
    });

    pollChanges();
  }

  private inline function pollChanges(): Void {
    while(true) {
      var files: Array<String> = Thread.readMessage(true);

      if(files != null && files.length > 0) {
        var clazz: Class<Dynamic> = Type.resolveClass("Runner");
        if(clazz != null) {
          var fields: Array<String> = Type.getClassFields(clazz);
          for(f in fields) {
            if(f == "start") {
              continue;
            }
            interp.variables.set(f, Reflect.field(clazz, f));
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

  public static function hxeval(string: String) {
    var ast = parser.parseString(string);
    return interp.execute(ast);
  }

}
