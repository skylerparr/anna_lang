package tests;
import lang.EmptyAtomException;
import anna_unit.Assert;
@:build(Macros.build())
class AtomTest {

  private static var atom1: Atom = @atom"foo";
  public static function shouldCreateAnAtomVariable(): Void {
    Assert.areEqual(atom1.toAnnaString(), ':foo');
  }

  private static var atomArray: Array<Atom> = {
    atomArray = [];

    atomArray.push(@atom"foo");
    atomArray.push(@atom"bar");

    atomArray;
  }
  public static function shouldCreateAtomWithStaticInitializer(): Void {
    Assert.areEqual(Anna.toAnnaString(atomArray), "#A[:foo, :bar]");
  }

  public static function shouldCreateAnAtomInAFunction(): Void {
    var a: Atom = @atom"foo";
    Assert.areEqual(a.toAnnaString(), ':foo');
  }

  public static function shouldCreateAnAtomWithinAConstructor(): Void {
    var ac: AtomContainer = new AtomContainer(@atom"fooey");
    Assert.areEqual(Anna.toAnnaString(ac.args), ':fooey');
  }

  public static function shouldCreateArrayOfAtomsInAConstructor(): Void {
    var ac: ArrayAtomContainer = new ArrayAtomContainer([@atom"cat", @atom"baz"]);
    Assert.areEqual(Anna.toAnnaString(ac.args), "#A[:cat, :baz]");
  }

  public static function shouldCreateAtomAsFunctionArgs(): Void {
    var tuple: Tuple = Tuple.push(@tuple[], @atom"benus");
    Assert.areEqual(tuple.toAnnaString(), '[:benus]');
  }

  public static function shouldNotBeAbleToCreateAnEmptyAtom(): Void {
    Assert.throwsException(function() {
      var atom: Atom = @atom"";
    }, EmptyAtomException);
  }

}

class AtomContainer {
  public var args: Atom;

  public function new(args: Atom) {
    this.args = args;
  }
}

class ArrayAtomContainer {
  public var args: Array<Atom>;

  public function new(args: Array<Atom>) {
    this.args = args;
  }
}
