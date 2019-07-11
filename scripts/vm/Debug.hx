package vm;

import haxe.macro.Type.Ref;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.TVar;
import haxe.macro.Context;
import haxe.macro.Expr;

class Debug {

  macro public static function pry(): Expr {
    var localVars: Map<String, TVar> = Context.getLocalTVars();
    var cls: Null<Ref<ClassType>> =  Context.getLocalClass();

    var fields = cls.get().fields.get();

    var codeArray: Array<String> = [];

    for(varVal in localVars.keys()) {
      codeArray.push('varMap.set("${varVal}", ${varVal});');
    }
    for(field in fields) {
      switch(field.kind) {
        case FVar(AccNormal,AccNormal):
          codeArray.push('varMap.set("${field.name}", ${field.name});');
        case _:
      }
    }
    var varCode: Expr = Macros.haxeToExpr(codeArray.join('\n'));

    return macro {
      if(!vm.Inspector.paused) {
        var currentThread: cpp.vm.Thread = cpp.vm.Thread.current();
        vm.Inspector.debugThread = currentThread;
        var varMap: Map<String, Dynamic> = new Map<String, Dynamic>();
        $e{varCode}
        Logger.inspect('pry stopped at ${Context.currentPos()}');
        while(true) {
          var message: DebugMessage = cpp.vm.Thread.readMessage(true);
          if(message == null) {
            continue;
          }
          switch(message) {
            case vm.DebugMessage.PRINT_VAR(name):
              Logger.inspect(varMap.get(name));
            case vm.DebugMessage.LIST_VARS:
              Logger.inspect(varMap);
            case vm.DebugMessage.GET_VAR(name, thread):
              thread.sendMessage(varMap.get(name));
            case vm.DebugMessage.RESUME:
              vm.Inspector.debugThread = null;
              break;
          }
        }
      }
    }

  }
}
