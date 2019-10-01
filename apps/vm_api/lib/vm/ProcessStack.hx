package vm;

import core.BaseObject;
interface ProcessStack extends BaseObject {

 function add(callStack: AnnaCallStack): Void;
 function execute(): Void;
 function getVariablesInScope(): Map<String, Dynamic>;
  function printStackTrace(): Void;
}