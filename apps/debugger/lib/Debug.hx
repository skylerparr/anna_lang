package ;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.Ref;
import haxe.macro.Type.TVar;
import lang.macros.Macros;

class Debug {

  macro public static function pry(message: Expr = null): Expr {
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

    var pryMsgExpr = switch(message.expr) {
      case EConst(CIdent('null')):
        Macros.haxeToExpr('"pry stopped at ${Context.currentPos()}"');
      case _:
        message;
    }

    var currentPos: Expr = Macros.haxeToExpr('"${Context.currentPos()}"');

    return macro {
      if(!Inspector.stopped && cpp.vm.Thread.current().handle != Inspector.ttyThread.handle) {
        var currentThread: cpp.vm.Thread = cpp.vm.Thread.current();
        Inspector.debugThread = currentThread;
        var varMap: Map<String, Dynamic> = new Map<String, Dynamic>();
        varMap.set("this", this);
        $e{varCode}
        Logger.inspect($e{pryMsgExpr});
        while(true) {
          var message: DebugMessage = cpp.vm.Thread.readMessage(true);
          if(message == null) {
            continue;
          }
          switch(message) {
            case DebugMessage.PRINT_VAR(name):
              Logger.inspect(varMap.get(name));
            case DebugMessage.LIST_VARS:
              Logger.inspect(varMap);
            case DebugMessage.GET_VAR(name, thread):
              thread.sendMessage(varMap.get(name));
            case DebugMessage.CURRENT_POS:
              Logger.inspect($e{currentPos});
            case DebugMessage.RESUME:
              Inspector.debugThread = null;
              break;
          }
        }
      }
    }

  }
}
