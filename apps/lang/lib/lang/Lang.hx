package lang;
import hscript.Macro;
import hscript.Parser;
class Lang {
  public static function stringToAst(string:String):Tuple {
    var parser: Parser = new Parser();
    parser.allowMetadata = true;
    parser.allowTypes = true;
    var ast = parser.parseString(string);
    var pos = { max: 12, min: 0, file: null };
    var ast = new Macro(pos).convert(ast);

    trace(ast);

    return Tuple.create([]);
  }
}
