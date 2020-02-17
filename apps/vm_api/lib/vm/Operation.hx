package vm;

import lang.macros.AnnaLang;
interface Operation {

  var hostModule: Atom;
  var hostFunction: Atom;
  var lineNumber: Int;
  var annaLang: AnnaLang;

  function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void;

  function isRecursive(): Bool;

  function toString(): String;
}