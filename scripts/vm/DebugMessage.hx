package vm;

import sys.thread.Thread;
enum DebugMessage {
  RESUME;
  PRINT_VAR(varName: String);
  GET_VAR(varName: String, thread: Thread);
  LIST_VARS;
  CURRENT_POS;
}