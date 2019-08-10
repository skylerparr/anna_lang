package vm;

enum KernelMessage {
  STOP;
  SCHEDULE(process: Process);
  RECEIVE(process: Process, matcher: Dynamic);
  SEND(process: Process, payload: Dynamic);
}