package compiler;

import hscript.Parser;
import hscript.Interp;
import hscript.Printer;
using lang.AtomSupport;
using StringTools;

@:build(lang.macros.ValueClassImpl.build())
class Compiler {
  @field public static var parser: Parser;
  @field public static var interp: Interp;
  @field public static var printer: Printer;

  public static function start(): Atom {
    printer = new Printer();
    parser = Native.callStaticField('Main', 'parser');
    interp = Native.callStaticField('Main', 'interp');
    return 'ok'.atom();
  }
//
//  public static function interpHaxe(string: String): Dynamic {
//    var ast = parser.parseString(string);
//    interp.variables.set('AtomSupport', AtomSupport);
//    try {
//      return interp.execute(ast);
//    } catch(e: Dynamic) {
//      return string;
//    }
//  }
//
//  public static function compileAll(): Atom {
//    Module.stop();
//    Module.start();
//    DefinedTypes.stop();
//    DefinedTypes.start();
//
//    var lib: String = '${Sys.getCwd()}lib/';
//    var files: Array<String> = FileSystem.readDirectory(lib);
//    for(file in files) {
//      compile(file);
//    }
//
//    var types: Array<TypeSpec> = DefinedTypes.typesDefined();
//    for(type in types) {
//      var haxeCode = HaxeTypeCodeGen.generate(type);
//      saveHaxe(haxeCode);
//    }
//
//    var modules: Array<ModuleSpec> = Module.modulesDefined();
//    for(module in modules) {
//      var haxeCode = HaxeModuleCodeGen.generate(module);
//
//      saveHaxe(haxeCode);
//    }
//
//    Native.callStatic("Runtime", "recompile", []);
//    return 'ok'.atom();
//  }
//
//  public static function saveHaxe(haxeCode: String): Void {
//    var packageName: String = haxeCode.split('\n')[0].replace('package', '').replace(';', '').trim().replace('.', '/');
//    var packageFrags: Array<String> = packageName.split('/');
//    var currentPackagePath: String = '';
//    for(pack in packageFrags) {
//      currentPackagePath += pack + '/';
//      FileSystem.createDirectory('${Sys.getCwd()}scripts/${currentPackagePath}');
//    }
//    var fileName: String = getClassName(haxeCode);
//    var outFile: String = '${Sys.getCwd()}scripts/${packageName}/${fileName}.hx';
//    File.saveContent(outFile, haxeCode);
//  }
//
//  public static function compile(filePath: String): Void {
//    var lib: String = 'lib/';
//    var outputfilePath = '${Sys.getCwd()}${lib}${filePath}';
//    var content: String = File.getContent(outputfilePath);
//    var ast = LangParser.toAST(content);
//    ASTParser.parse(ast);
//  }
//
//  private static inline function getClassName(code: String): String {
//    var classIndex: Int = code.indexOf('class ') + 'class '.length;
//    var className: String = '';
//    while(true) {
//      var char: String = code.charAt(classIndex++);
//      if(char == ' ') {
//        break;
//      }
//      className += char;
//    }
//    return className;
//  }
//
  public static function subscribeAfterCompile(fun: Void -> Void): Atom {
    Native.callStaticField("Main", "compilerCompleteCallbacks").push(fun);
    return 'ok'.atom();
  }
}