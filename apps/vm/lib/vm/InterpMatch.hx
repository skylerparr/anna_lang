package vm;
import haxe.macro.Expr;
class InterpMatch implements Operation {
  public var ast: Expr;

  public var hostModule: Atom;
  public var hostFunction: Atom;
  public var lineNumber: Int;

  public function new(ast: Expr, hostModule: Atom, hostFunction: Atom, lineNumber: Int) {
    this.ast = ast;

    this.hostModule = hostModule;
    this.hostFunction = hostFunction;
    this.lineNumber = lineNumber;
  }

  public function execute(scopeVariables: Map<String, Dynamic>, processStack: ProcessStack): Void {
    IO.inspect(ast);
    IO.inspect(scopeVariables);
  }

  public function isRecursive(): Bool {
    return false;
  }

  public function toString(): String {
    return '${Atom.to_s(hostModule)}.${Atom.to_s(hostFunction)}():${lineNumber}';
  }
}
