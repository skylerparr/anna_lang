package vm;

enum ProcessState {
  READY;
  RUNNING;
  COMPLETE;
  STOPPED;
  WAITING;
  SLEEPING;
  KILLED;
}