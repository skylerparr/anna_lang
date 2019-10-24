package vm;

import core.BaseObject;
interface AnnaCallStack extends BaseObject {
  var operations: Array<Operation>;
  var scopeVariables: Map<String, Dynamic>;

 function execute(processStack: ProcessStack): Void;

 function finalCall(): Bool;

  function toString(): String;
}