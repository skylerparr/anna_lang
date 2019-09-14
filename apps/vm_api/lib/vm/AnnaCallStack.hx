package vm;

interface AnnaCallStack {
  var operations: Array<Operation>;
  var scopeVariables: Map<String, Dynamic>;
  var tailCall: Bool;

 function execute(processStack: ProcessStack): Void;

 function finalCall(): Bool;

  function toString(): String;
}