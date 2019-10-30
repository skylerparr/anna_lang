package ;
class IO {
  public static function print(str: String): Atom {
    #if cpp
    cpp.Lib.print(str);
    #elseif python
    trace(str);
    #elseif js
    trace(str);
    js.Node.console.log(str);
    #end
    return Atom.create('ok');
  }

  public static function println(str: String): Atom {
    #if cpp
    cpp.Lib.print(str + '\r\n');
    #elseif python
    trace(str + '\r\n');
    #elseif js
    trace(str);
    js.Node.console.log(str);
    #end
    return Atom.create('ok');
  }

  public static function inspect(value: Dynamic, label: String = null): Dynamic {
    Logger.inspect(value, label);
    return value;
  }

  public static function gets(): String {
    #if (cpp || python)
    var char: Int = Sys.getChar(false);
    return String.fromCharCode(char);
    #elseif js
    trace('gets');
    js.Node.process.stdin.read(1);
    return '';
    #end
  }

  public static function getsCharCode(): Int {
    #if (cpp || python)
    return Sys.getChar(false);
    #elseif js
    trace('charcode');
    var readline = js.Node.require('readline').createInterface({
      input: js.Node.process.stdin,
      output: js.Node.process.stdout
    });
    readline.question('', function(value) {
     trace(value);
    });
    return 25;
    #end
  }
}
