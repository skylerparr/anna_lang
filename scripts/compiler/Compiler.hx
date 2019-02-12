package compiler;

import sys.FileSystem;
import haxe.macro.Printer;
import hscript.Interp;
import hscript.Parser;
import lang.LangParser;
import sys.io.File;

using lang.AtomSupport;
using StringTools;

@:build(macros.ValueClassImpl.build())
class Compiler {
  @field public static var parser: Parser;
  @field public static var interp: Interp;
  @field public static var printer: Printer;

  public static function start(): lang.Types.Atom {
    printer = new Printer();
    parser = Native.callStaticField('Main', 'parser');
    interp = Native.callStaticField('Main', 'interp');
    return 'ok'.atom();
  }

  public static function inspect(): Void {
    var expr = CodeGen.parse("'foo'");
    trace(expr);
  }

  public static function fn(): #if macro haxe.macro.Expr #else Dynamic #end {
    #if macro
    return CodeGen.fn();
    #else
    return interp.execute(CodeGen._fn());
    #end
  }

  public static function parse(string: String): #if macro haxe.macro.Expr #else hscript.Expr #end {
    #if macro
    return CodeGen.parse();
    #else
    return interp.execute(CodeGen._fn());
    #end
  }

  public static function compile(filePath: String): Void {
    var lib: String = 'lib/';
    var outputfilePath = '${Sys.getCwd()}${lib}${filePath}';
    var content: String = File.getContent(outputfilePath);
    var ast = LangParser.toAST(content);
    var haxeCode: String = LangParser.toHaxe(ast);
    var packageName: String = haxeCode.split('\n')[0].replace('package', '').replace(';', '').trim().replace('.', '/');
    var packageFrags: Array<String> = packageName.split('/');
    var currentPackagePath: String = '';
    for(pack in packageFrags) {
      currentPackagePath += pack + '/';
      FileSystem.createDirectory('${Sys.getCwd()}scripts/${currentPackagePath}');
    }
    var outFile: String = '${Sys.getCwd()}scripts/${packageName}/${filePath.replace(".anna", ".hx")}';
    File.saveContent(outFile, haxeCode);
    Native.callStatic("Runtime", "recompile", []);
  }
}