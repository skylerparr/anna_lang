package lang;

import lang.macros.MacroLogger;
import haxe.macro.Expr;

interface CustomType {
  function toAnnaString(): String;
}