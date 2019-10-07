package lang;

import lang.macros.MacroLogger;
import haxe.macro.Expr;

interface CustomType {
  var variables: Map<String, String>;
  function toAnnaString(): String;
}