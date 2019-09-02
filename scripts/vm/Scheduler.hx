package vm;
interface Scheduler {
  function start(): Atom;
  function stop(): Atom;
  function update(): Dynamic;
}
