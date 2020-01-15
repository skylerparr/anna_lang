package lang;

import EitherEnums.Either10;
import EitherEnums.Either11;
import EitherEnums.Either12;
import EitherEnums.Either13;
import EitherEnums.Either14;
import EitherEnums.Either15;
import EitherEnums.Either16;
import EitherEnums.Either17;
import EitherEnums.Either18;
import EitherEnums.Either19;
import EitherEnums.Either1;
import EitherEnums.Either20;
import EitherEnums.Either21;
import EitherEnums.Either22;
import EitherEnums.Either23;
import EitherEnums.Either24;
import EitherEnums.Either25;
import EitherEnums.Either26;
import EitherEnums.Either2;
import EitherEnums.Either3;
import EitherEnums.Either4;
import EitherEnums.Either5;
import EitherEnums.Either6;
import EitherEnums.Either7;
import EitherEnums.Either8;
import EitherEnums.Either9;
class EitherSupport {
  public static inline function getValue(e: Dynamic): Dynamic {
    if(e == null) {
      e = Atom.create("nil");
    }
    return e;
  }

}