package ;

import lang.AmbiguousFunctionException;
import lang.CustomType;
import lang.EitherSupport;
using lang.AtomSupport;
@:rtti
class Tuple implements CustomType {

  public static function elem(t: Tuple, index: Int): Any {
    var retVal = Reflect.field(t, 'var${index + 1}');
    if(retVal == null) {
      return 'nil'.atom();
    }
    return EitherSupport.getValue(retVal);
  }
  
  public static function create(val: Array<Any>): Tuple {
    return {
      switch(val) {
        case []:
          new Tuple0();
        case [var1]:
          new Tuple1(var1);
        case [var1, var2]:
          new Tuple2(var1, var2);
        case [var1, var2, var3]:
          new Tuple3(var1, var2, var3);
        case [var1, var2, var3, var4]:
          new Tuple4(var1, var2, var3, var4);
        case [var1, var2, var3, var4, var5]:
          new Tuple5(var1, var2, var3, var4, var5);
        case [var1, var2, var3, var4, var5, var6]:
          new Tuple6(var1, var2, var3, var4, var5, var6);
        case [var1, var2, var3, var4, var5, var6, var7]:
          new Tuple7(var1, var2, var3, var4, var5, var6, var7);
        case [var1, var2, var3, var4, var5, var6, var7, var8]:
          new Tuple8(var1, var2, var3, var4, var5, var6, var7, var8);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9]:
          new Tuple9(var1, var2, var3, var4, var5, var6, var7, var8, var9);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10]:
          new Tuple10(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11]:
          new Tuple11(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12]:
          new Tuple12(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13]:
          new Tuple13(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14]:
          new Tuple14(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15]:
          new Tuple15(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16]:
          new Tuple16(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17]:
          new Tuple17(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18]:
          new Tuple18(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19]:
          new Tuple19(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20]:
          new Tuple20(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21]:
          new Tuple21(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22]:
          new Tuple22(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23]:
          new Tuple23(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24]:
          new Tuple24(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24, var25]:
          new Tuple25(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24, var25);
        case [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24, var25, var26]:
          new Tuple26(var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24, var25, var26);
        case _:
          throw new AmbiguousFunctionException('Cannot create a tuple larger than 26 elements.');
      }
    }
  }

  public function asArray(): Array<Any> {
    return [];
  }

  public static function array(tuple: Tuple): Array<Any> {
    return tuple.asArray();
  }

  public static function push(tuple: Tuple, value: Any): Tuple {
    var newArray: Array<Any> = tuple.asArray();
    newArray.push(value);
    return create(newArray);
  }

  public static function addElemAt(tuple: Tuple, value: Any, index: Int): Tuple {
    var newArray: Array<Any> = tuple.asArray();
    newArray.insert(index, value);
    return create(newArray);
  }

  public static function removeElemAt(tuple: Tuple, index: Int): Tuple {
    var newArray: Array<Any> = tuple.asArray();
    var counter = 0;
    for(a in newArray) {
      if(counter++ == index) {
        newArray.remove(a);
        break;
      }
    }
    return create(newArray);
  }

  public static function length(tuple: Tuple): Int {
    return tuple.asArray().length;
  }

  public var __annaString: String;

  public function toAnnaString(): String {
    if(__annaString == null) {
      var stringFrags: Array<String> = [];
      var vars: Array<Any> = asArray();
      for(v in vars) {
        stringFrags.push(Anna.toAnnaString(v));
      }
      __annaString = '[${stringFrags.join(', ')}]';
    }
    return __annaString;
  }
}

@:generic
class Tuple0 extends Tuple implements CustomType {

  public inline function new() {
  }

  override public inline function asArray(): Array<Any> {
    return [];
  }

  override public function toAnnaString(): String {
    return '[]';
  }
}

@:generic
class Tuple1<A> extends Tuple implements CustomType {

  public var var1(default, never): A;

  public inline function new(var1: A) {
    Reflect.setField(this, 'var1', var1);
  }

  override public inline function asArray(): Array<Any> {
    return [var1];
  }


}

@:generic
class Tuple2<A, B> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;

  public inline function new(var1: A, var2: B) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2];
  }


}

@:generic
class Tuple3<A, B, C> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;

  public inline function new(var1: A, var2: B, var3: C) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3];
  }


}

@:generic
class Tuple4<A, B, C, D> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;

  public inline function new(var1: A, var2: B, var3: C, var4: D) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4];
  }


}

@:generic
class Tuple5<A, B, C, D, E> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5];
  }


}

@:generic
class Tuple6<A, B, C, D, E, F> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6];
  }


}

@:generic
class Tuple7<A, B, C, D, E, F, G> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7];
  }


}

@:generic
class Tuple8<A, B, C, D, E, F, G, H> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8];
  }


}

@:generic
class Tuple9<A, B, C, D, E, F, G, H, I> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9];
  }


}

@:generic
class Tuple10<A, B, C, D, E, F, G, H, I, J> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10];
  }


}

@:generic
class Tuple11<A, B, C, D, E, F, G, H, I, J, K> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11];
  }


}

@:generic
class Tuple12<A, B, C, D, E, F, G, H, I, J, K, L> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12];
  }


}

@:generic
class Tuple13<A, B, C, D, E, F, G, H, I, J, K, L, M> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13];
  }


}

@:generic
class Tuple14<A, B, C, D, E, F, G, H, I, J, K, L, M, N> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14];
  }


}

@:generic
class Tuple15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15];
  }


}

@:generic
class Tuple16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16];
  }


}

@:generic
class Tuple17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17];
  }


}

@:generic
class Tuple18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18];
  }


}

@:generic
class Tuple19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;
  public var var19(default, never): S;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R, var19: S) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
    Reflect.setField(this, 'var19', var19);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19];
  }


}

@:generic
class Tuple20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;
  public var var19(default, never): S;
  public var var20(default, never): T;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R, var19: S, var20: T) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
    Reflect.setField(this, 'var19', var19);
    Reflect.setField(this, 'var20', var20);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20];
  }


}

@:generic
class Tuple21<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;
  public var var19(default, never): S;
  public var var20(default, never): T;
  public var var21(default, never): U;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R, var19: S, var20: T, var21: U) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
    Reflect.setField(this, 'var19', var19);
    Reflect.setField(this, 'var20', var20);
    Reflect.setField(this, 'var21', var21);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21];
  }


}

@:generic
class Tuple22<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;
  public var var19(default, never): S;
  public var var20(default, never): T;
  public var var21(default, never): U;
  public var var22(default, never): V;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R, var19: S, var20: T, var21: U, var22: V) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
    Reflect.setField(this, 'var19', var19);
    Reflect.setField(this, 'var20', var20);
    Reflect.setField(this, 'var21', var21);
    Reflect.setField(this, 'var22', var22);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22];
  }


}

@:generic
class Tuple23<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;
  public var var19(default, never): S;
  public var var20(default, never): T;
  public var var21(default, never): U;
  public var var22(default, never): V;
  public var var23(default, never): W;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R, var19: S, var20: T, var21: U, var22: V, var23: W) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
    Reflect.setField(this, 'var19', var19);
    Reflect.setField(this, 'var20', var20);
    Reflect.setField(this, 'var21', var21);
    Reflect.setField(this, 'var22', var22);
    Reflect.setField(this, 'var23', var23);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23];
  }


}

@:generic
class Tuple24<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;
  public var var19(default, never): S;
  public var var20(default, never): T;
  public var var21(default, never): U;
  public var var22(default, never): V;
  public var var23(default, never): W;
  public var var24(default, never): X;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R, var19: S, var20: T, var21: U, var22: V, var23: W, var24: X) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
    Reflect.setField(this, 'var19', var19);
    Reflect.setField(this, 'var20', var20);
    Reflect.setField(this, 'var21', var21);
    Reflect.setField(this, 'var22', var22);
    Reflect.setField(this, 'var23', var23);
    Reflect.setField(this, 'var24', var24);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24];
  }


}

@:generic
class Tuple25<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;
  public var var19(default, never): S;
  public var var20(default, never): T;
  public var var21(default, never): U;
  public var var22(default, never): V;
  public var var23(default, never): W;
  public var var24(default, never): X;
  public var var25(default, never): Y;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R, var19: S, var20: T, var21: U, var22: V, var23: W, var24: X, var25: Y) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
    Reflect.setField(this, 'var19', var19);
    Reflect.setField(this, 'var20', var20);
    Reflect.setField(this, 'var21', var21);
    Reflect.setField(this, 'var22', var22);
    Reflect.setField(this, 'var23', var23);
    Reflect.setField(this, 'var24', var24);
    Reflect.setField(this, 'var25', var25);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24, var25];
  }


}

@:generic
class Tuple26<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z> extends Tuple implements CustomType {

  public var var1(default, never): A;
  public var var2(default, never): B;
  public var var3(default, never): C;
  public var var4(default, never): D;
  public var var5(default, never): E;
  public var var6(default, never): F;
  public var var7(default, never): G;
  public var var8(default, never): H;
  public var var9(default, never): I;
  public var var10(default, never): J;
  public var var11(default, never): K;
  public var var12(default, never): L;
  public var var13(default, never): M;
  public var var14(default, never): N;
  public var var15(default, never): O;
  public var var16(default, never): P;
  public var var17(default, never): Q;
  public var var18(default, never): R;
  public var var19(default, never): S;
  public var var20(default, never): T;
  public var var21(default, never): U;
  public var var22(default, never): V;
  public var var23(default, never): W;
  public var var24(default, never): X;
  public var var25(default, never): Y;
  public var var26(default, never): Z;

  public inline function new(var1: A, var2: B, var3: C, var4: D, var5: E, var6: F, var7: G, var8: H, var9: I, var10: J, var11: K, var12: L, var13: M, var14: N, var15: O, var16: P, var17: Q, var18: R, var19: S, var20: T, var21: U, var22: V, var23: W, var24: X, var25: Y, var26: Z) {
    Reflect.setField(this, 'var1', var1);
    Reflect.setField(this, 'var2', var2);
    Reflect.setField(this, 'var3', var3);
    Reflect.setField(this, 'var4', var4);
    Reflect.setField(this, 'var5', var5);
    Reflect.setField(this, 'var6', var6);
    Reflect.setField(this, 'var7', var7);
    Reflect.setField(this, 'var8', var8);
    Reflect.setField(this, 'var9', var9);
    Reflect.setField(this, 'var10', var10);
    Reflect.setField(this, 'var11', var11);
    Reflect.setField(this, 'var12', var12);
    Reflect.setField(this, 'var13', var13);
    Reflect.setField(this, 'var14', var14);
    Reflect.setField(this, 'var15', var15);
    Reflect.setField(this, 'var16', var16);
    Reflect.setField(this, 'var17', var17);
    Reflect.setField(this, 'var18', var18);
    Reflect.setField(this, 'var19', var19);
    Reflect.setField(this, 'var20', var20);
    Reflect.setField(this, 'var21', var21);
    Reflect.setField(this, 'var22', var22);
    Reflect.setField(this, 'var23', var23);
    Reflect.setField(this, 'var24', var24);
    Reflect.setField(this, 'var25', var25);
    Reflect.setField(this, 'var26', var26);
  }

  override public inline function asArray(): Array<Any> {
    return [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, var21, var22, var23, var24, var25, var26];
  }


}