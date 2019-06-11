package vm;

interface Operation {
  function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void;
}