package vm;

interface ProcessStack {

 function add(callStack: AnnaCallStack): Void;
 function execute(): Void;
 function getVariablesInScope(): Map<String, Dynamic>;
  function printStackTrace(): Void;
}