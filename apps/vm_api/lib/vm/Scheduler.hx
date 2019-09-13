package vm;
//import EitherEnums.Either1;
//import Tuple.Tuple2;
interface Scheduler {
  /**
  * Starts the vm if it's not already running.
  * returns @_"ok" if sucessfully started @_"already_started" if already started
  */
  function start(): Atom;
  /**
  * pauses the scheduler. All the state is unchanged
  * returns @_"ok" if sucessfully paused @_"already_paused" if already paused, @_"not_running" if not running
  */
  function pause(): Atom;
  /**
  * resumes the scheduler if paused
  * returns @_"ok" if successfully resume @_"already_running" if already running, @_"not_running" if not running
  */
  function resume(): Atom;
  /**
  * stops the scheduler and clears all scheduler data, resume is not available
  * returns @_"ok" if successfully stopped, @_"not_running" if not running
  */
  function stop(): Atom;
  /**
  * pauses the process for number of milliseconds
  */
  function sleep(pid: Pid, milliseconds: Float): Pid;
  /**
  * sends a process some data
  * returns @_"ok" if success, @_"error" if fail
  */
  function send(pid: Pid, payload: Dynamic): Atom;
  /**
  * Tells the process to check its mailbox and if the mailbox is empty
  * block until mail is handled
  */
  function receive(process: Pid, callback: Dynamic->Void, timeout: Float = -1): Void;
  /**
  * This must be called as the main async loop.
  */
  function update(): Void;

//  function spawn(fn: Void->Dynamic): Pid;
//
//  function spawn_link(fn: Void->Dynamic): Tuple2<Either1<Atom>, Either1<String>>;
//
//  function monitor(pid: Pid): Atom;
//
//  function demonitor(pid: Pid): Atom;
//
//  function flag(pid: Pid, flag: Atom, value: Atom): Atom;
//
//  function exit(pid: Pid, signal: Atom): Atom;
//
//  function apply(fn: Dynamic, onComplete: Dynamic->Void): Void;
}
