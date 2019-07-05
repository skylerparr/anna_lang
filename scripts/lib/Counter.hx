package lib;

import vm.Process;
import vm.PushStack;
import vm.InvokeFunction;
import vm.Operation;
using lang.AtomSupport;

@:build(Macros.build())
class Counter {

//  private static var _increment_Int__Void_0: Array<Operation> = {
//    _increment_Int__Void_0 = [];
//
//    _increment_Int__Void_0.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), 'start']]));
//    _increment_Int__Void_0.push(new PushStack("Counter".atom(), 'countdown_Int__Void'.atom(), [@tuple['var'.atom(), 'count']]));
//    _increment_Int__Void_0.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), 'end']]));
//    _increment_Int__Void_0;
//  }
//
//  public static function increment_Int__Void(count: Int): Array<Operation> {
//    return {
//      switch(count) {
//        case _:
//          _increment_Int__Void_0;
//        }
//    }
//  }
//
//  public static function ___increment_Int__Void_args(): Array<String> {
//    var args: Array<String> = [];
//    args.push('count');
//    return args;
//  }
//
//  public static var _countdown_Int__Void_0: Array<Operation> = {
//    _countdown_Int__Void_0 = [];
//
//    _countdown_Int__Void_0.push(new InvokeFunction(Process.sleep, [@tuple['const'.atom(), 500]]));
//    _countdown_Int__Void_0.push(new InvokeFunction(IO.inspect, [@tuple['var'.atom(), 'count']]));
//    _countdown_Int__Void_0.push(new InvokeFunction(Anna.subtract, [@tuple['var'.atom(), 'count'], @tuple['const'.atom(), 1]]));
//    _countdown_Int__Void_0.push(new PushStack("Counter".atom(), 'countdown_Int__Void'.atom(), [@tuple['var'.atom(), "$$$"]]));
//
//    _countdown_Int__Void_0;
//  }
//
//  public static var _countdown_Int__Void_1: Array<Operation> = {
//    _countdown_Int__Void_1 = [];
//    _countdown_Int__Void_1.push(new InvokeFunction(Process.sleep, [@tuple['const'.atom(), 500]]));
//    _countdown_Int__Void_1.push(new InvokeFunction(IO.inspect, [@tuple['const'.atom(), 0]]));
//
//    _countdown_Int__Void_1;
//  }
//
//  public static function countdown_Int__Void(count: Int): Array<Operation> {
//    return {
//      switch(count) {
//        case 0:
//          _countdown_Int__Void_1;
//        case _:
//          _countdown_Int__Void_0;
//      }
//    }
//  }
//
//  public static function ___countdown_Int__Void_args(): Array<String> {
//    var args: Array<String> = [];
//    args.push('count');
//    return args;
//  }

}