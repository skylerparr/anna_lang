package vm;

interface Function {
  var args: Array<Dynamic>;
  var fn: Dynamic;
  var scope: Map<String, Dynamic>;

  function invoke(args: Array<Dynamic>): Array<Operation>;
}