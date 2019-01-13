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

class Anna {
  private static var parser: Parser = new Parser();
  private static var interp: Interp;

  private static var mainThread: Thread;
  private static var ready: Bool = false;

  public static function main() {
    Native;
    AtomSupport.atoms = new HashTableAtoms();
    GlobalStore.start();
    new Anna();
  }

  public function new() {
    var basePath: String = PathSettings.applicationBasePath;
    interp = HScriptEval.interp;
    var variables = interp.variables;
    variables.set("rc", function() {
      Runtime.clean();
      Runtime.recompile();
    });
    variables.set('Types', Types);
    variables.set('a', function(arg: String): Atom {
      return arg.atom();
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
      ['${basePath}src/'], ['hscript'], onComplete);
    });

    pollChanges();
  }

  private inline function pollChanges(): Void {
    while(true) {
      Sys.sleep(0.25);
      var files: Array<String> = Thread.readMessage(false);

      if(files != null) {
        if(!ready) {
          var clazz: Class<Dynamic> = Type.resolveClass("App");
          if(clazz != null) {
            var fun = Reflect.field(clazz, "start");
            Reflect.callMethod(clazz, fun, []);
          }
          ready = true;
        }
      }
    }
  }

//  private inline function setupMacros(): Void {
//    variables.set("s", function(o: Dynamic): Bool {
//      o.parser = parser;
//      o.interp = interp;
//      return true;
//    });
//    variables.set("hxeval", function(string: String): Dynamic {
//      return hxeval(string);
//    });
//    variables.set("macro", function(string: String): Dynamic {
//      var ast = parser.parseString(string);
//      var pos = { max: 12, min: 0, file: null };
//      return new Macro(pos).convert(ast);
//    });
//    variables.set("hx", function(string: String): Dynamic {
//      return string;
//    });
//    variables.set("ast", function(string: String): Dynamic {
//      return parser.parseString(string);
//    });
//    variables.set("Anna", Anna);
//    variables.set("fields", function(o: Dynamic): Dynamic {
//      return Reflect.fields(o);
//    });
//
//    hxeval('s(Compiler)');
//    hxeval('s(Kernel)');
//  }
//
//  public static function hxeval(string: String) {
//    var ast = parser.parseString(string);
//    return interp.execute(ast);
//  }
//
//  private function onRecompile(files: Array<String>): Void {
//    setupMacros();
//  }

}
