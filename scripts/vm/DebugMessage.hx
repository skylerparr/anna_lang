package vm;

import cpp.vm.Thread;
enum DebugMessage {
  RESUME;
  PRINT_VAR(varName: String);
  GET_VAR(varName: String, thread: Thread);
  LIST_VARS;
  CURRENT_POS;
}