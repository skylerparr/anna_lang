package vm;

interface Function {
  var args: Array<Dynamic>;
  var fn: Dynamic;

  function invoke(args: Array<Dynamic>): Array<Operation>;
}