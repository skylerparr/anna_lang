package vm;

interface Operation {
  function execute(scopeVariables: Map<Tuple, Dynamic>, processStack: ProcessStack): Void;
}