package lang;

import compiler.CodeGen;
class LangParser {

  public static function parse(body: String): #if macro haxe.macro.Expr #else hscript.Expr #end {
    var sample: String = "
    defmodule(Foo, do:
    end

    {func: 'defmodule'.atom(), args: ['foo'.atom(), [{'do'.atom(), []}]], line: 0}

    defmodule('foo'.atom(), body(do:))
    ";

    var b: String = "trace('remember to assign this')";
    #if macro
    return CodeGen.parse(b);
    #else
    return CodeGen._parse(b);
    #end
  }
  
}