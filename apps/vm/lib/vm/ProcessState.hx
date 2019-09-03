package vm;

enum ProcessState {
  READY;
  RUNNING;
  COMPLETE;
  WAITING;
  SLEEPING;
  KILLED;
  PAUSED;
}