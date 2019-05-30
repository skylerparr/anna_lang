package vm;

enum KernelMessage {
  STOP;
  SCHEDULE(process: Process);
}