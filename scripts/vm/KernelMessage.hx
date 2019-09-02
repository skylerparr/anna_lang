package vm;

enum KernelMessage {
  STOP;
  SCHEDULE(process: SimpleProcess);
  RECEIVE(process: SimpleProcess, matcher: Dynamic);
  SEND(process: SimpleProcess, payload: Dynamic);
}