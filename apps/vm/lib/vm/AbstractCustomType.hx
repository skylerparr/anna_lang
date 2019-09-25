package vm;

import lang.CustomType;
class AbstractCustomType implements CustomType {
  public function toAnnaString(): String {
    var fieldPairs: Array<String> = [];
    for(field in Reflect.fields(this)) {
      fieldPairs.push('${StringTools.replace(Anna.toAnnaString(field), '"', '')}: ${Anna.toAnnaString(Reflect.field(this, field))}');
    }
    return '{${fieldPairs.join(', ')}}';
  }
}