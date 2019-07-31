package lang;

import EitherEnums.Either13;
import EitherEnums.Either15;
import EitherEnums.Either14;
import EitherEnums.Either16;
import EitherEnums.Either17;
import EitherEnums.Either18;
import EitherEnums.Either19;
import EitherEnums.Either20;
import EitherEnums.Either21;
import EitherEnums.Either22;
import EitherEnums.Either23;
import EitherEnums.Either26;
import EitherEnums.Either25;
import EitherEnums.Either24;
import EitherEnums.Either12;
import EitherEnums.Either11;
import EitherEnums.Either10;
import EitherEnums.Either9;
import EitherEnums.Either8;
import EitherEnums.Either7;
import EitherEnums.Either6;
import EitherEnums.Either5;
import EitherEnums.Either4;
import EitherEnums.Either3;
import EitherEnums.Either2;
import EitherEnums.Either1;
class EitherSupport {
  public static function getValue(e: Dynamic): Dynamic {
    return switch(Type.getEnum(e)) {
      case Either1:
        switch(e) {
          case A(a):
            a;
        }
      case Either2:
        switch(e) {
          case A(a):
            a;
          case B(b):
            b;
          case _:
            throw "Unmatched";
        }
      case Either3:
        switch(e) {
          case A(a):
            a;
          case B(b):
            b;
          case C(c):
            c;
          case _:
            throw "Unmatched";
        }
      case Either4:
        switch(e) {
          case D(d):
            d;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either5:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either6:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either7:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either8:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either9:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either10:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either11:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either12:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either13:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either14:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either15:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either16:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either17:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either18:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either19:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;
          case S(s):
            s;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either20:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;
          case S(s):
            s;
          case T(t):
            t;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either21:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;
          case S(s):
            s;
          case T(t):
            t;
          case U(u):
            u;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either22:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;
          case S(s):
            s;
          case T(t):
            t;
          case U(u):
            u;
          case V(v):
            v;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either23:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;
          case S(s):
            s;
          case T(t):
            t;
          case U(u):
            u;
          case V(v):
            v;
          case W(w):
            w;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either24:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;
          case S(s):
            s;
          case T(t):
            t;
          case U(u):
            u;
          case V(v):
            v;
          case W(w):
            w;
          case X(x):
            x;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either25:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;
          case S(s):
            s;
          case T(t):
            t;
          case U(u):
            u;
          case V(v):
            v;
          case W(w):
            w;
          case X(x):
            x;
          case Y(y):
            y;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case Either26:
        switch(e) {
          case D(d):
            d;
          case E(e):
            e;
          case F(f):
            f;
          case G(g):
            g;
          case H(h):
            h;
          case I(i):
            i;
          case J(j):
            j;
          case K(k):
            k;
          case L(l):
            l;
          case M(m):
            m;
          case N(n):
            n;
          case O(o):
            o;
          case P(p):
            p;
          case Q(q):
            q;
          case R(r):
            r;
          case S(s):
            s;
          case T(t):
            t;
          case U(u):
            u;
          case V(v):
            v;
          case W(w):
            w;
          case X(x):
            x;
          case Y(y):
            y;
          case Z(z):
            z;

          case v:
            switch(v) {
              case A(a):
                a;
              case B(b):
                b;
              case C(c):
                c;
              case _:
                throw "Unmatched";
            }
        }
      case _:
        e;
    }
  }

}