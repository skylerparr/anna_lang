package vm;
import lang.FunctionClauseNotFound;
import lang.macros.AnnaLang;
class InvokeNativeFunctionOperation extends vm.AbstractInvokeFunction {
  private var func: Dynamic;
  private var args: LList;
  private var classString: String;
  private var funString: String;
  private var arrayArgs: Array<Dynamic>;

  public function new(fun: Dynamic, args: LList, classString: String, funString: String, hostModule: Atom, hostFunction: Atom, lineNumber: Int, annaLang: AnnaLang) {
    super(hostModule, hostFunction, lineNumber, annaLang);
    this.classString = classString;
    this.funString = funString;
    this.func = fun;
    this.args = args;

    arrayArgs = [];
    for(arg in LList.iterator(args)) {
      var tuple: Tuple = lang.EitherSupport.getValue(arg);
      arrayArgs.push(tuple);
    }
  }

  override public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    if(func == null) {
      Logger.inspect('InvokeNativeFunctionOperation: Function not found ${func}:${lineNumber}');
      IO.inspect('InvokeNativeFunctionOperation: Function not found ${func}:${lineNumber}');
      NativeKernel.crash(Process.self());
      return;
    }
    var invokeArgs: Array<Dynamic> = [];
    for(arg in arrayArgs) {
      var invokeArg: Dynamic = ArgHelper.extractArgValue(arg, scopeVariables, annaLang);
      invokeArgs.push(invokeArg);
    }
    var retVal: Dynamic = Reflect.callMethod(null, func, invokeArgs);
    if (retVal == null) {
      scopeVariables.set("$$$", Atom.create("nil"));
    } else {
      scopeVariables.set("$$$", retVal);
    }
  }
}
