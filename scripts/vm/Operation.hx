package vm;

interface Operation {

  var hostModule: String;
  var hostFunction: String;
  var lineNumber: Int;

  function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void;

  function toString(): String;
}