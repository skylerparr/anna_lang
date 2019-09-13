package vm;

enum KernelMessage {
  STOP;
  SCHEDULE(process: Pid);
  RECEIVE(process: Pid, matcher: Dynamic);
  SEND(process: Pid, payload: Dynamic);
}