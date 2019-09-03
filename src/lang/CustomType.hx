package lang;

import lang.macros.MacroLogger;
import haxe.macro.Expr;

interface CustomType {
  function toAnnaString(): String;
  function toHaxeString(): String;
  function toPattern(patternArgs: Array<KeyValue<String, String>> = null): String;
}