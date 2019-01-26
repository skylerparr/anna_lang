import haxe.CallStack;
import haxe.Constraints.IMap;
import haxe.macro.Context;
import haxe.macro.Printer;
import state.GlobalStore;
import lang.Types;
import core.PathSettings;
import hscript.Macro;
import hscript.Interp;
import hscript.Parser;
import lang.HashTableAtoms;
import lang.Atoms;
import lang.Atoms;
import lang.AtomSupport;
import cpp.vm.Thread;
import ihx.HScriptEval;

using lang.AtomSupport;

class Main {
  public static var parser: Parser = new Parser();
  public static var interp: Interp;

  private static var mainThread: Thread;
  private static var ready: Bool = false;

  public static function main() {
    Native;
    Random;
    CallStack.exceptionStack();
    CallStack.callStack();
    var m: IMap<String, String> = new Map<String, String>();
    m.keys();
    new Date(2018, 1, 1, 0, 0, 0).getTime();
    new Printer().printExpr(macro 'foo');
    AtomSupport.atoms = new HashTableAtoms();
    GlobalStore.start();
    new Main();
  }

  public function new() {
    var basePath: String = PathSettings.applicationBasePath;
    interp = HScriptEval.interp;
    var variables = interp.variables;
    variables.set("rc", function() {
      Runtime.recompile();
    });
    variables.set("clean", function() {
      Runtime.clean();
    });
    variables.set("c", function(file: String) {
      Runtime.compile(file, null);
    });
    variables.set('Types', Types);
    variables.set('a', function(arg: String): Atom {
      return arg.atom();
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
          var files = Runtime.loadAll();
          mainThread.sendMessage(files);
          loaded = true;
        } else {
          mainThread.sendMessage(files);
        }
      }

      Runtime.start('${basePath}scripts', '${basePath}out/',
      ['${basePath}src/'], ['hscript', 'deep_equal'], onComplete);
    });

    pollChanges();
  }

  private inline function pollChanges(): Void {
    while(true) {
      Sys.sleep(0.25);
      var files: Array<String> = Thread.readMessage(false);

      if(files != null && files.length > 0) {
        var clazz: Class<Dynamic> = Type.resolveClass("Anna");
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
            Reflect.callMethod(clazz, fun, []);
          }
          ready = true;
        }
      }
    }
  }

  public static function hxeval(string: String) {
    var ast = parser.parseString(string);
    return interp.execute(ast);
  }

}
