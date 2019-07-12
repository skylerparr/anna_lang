package vm;

interface Operation {

  var hostModule: Atom;
  var hostFunction: Atom;
  var lineNumber: Int;

  function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void;

  function isRecursive(): Bool;

  function toString(): String;
}