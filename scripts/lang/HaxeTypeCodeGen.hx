package lang;

import haxe.Template;
class HaxeTypeCodeGen {

  private static inline var classTemplate: String = 'package ::package_name::;
import lang.CustomType;
class ::class_name:: implements CustomType {
::foreach fields::
  public var ::name.value::(default, never): ::type.value::;::end::

  public inline function new(::constructor_args::) {
    ::foreach fields::Reflect.setField(this, "::name.value::", ::name.value::);
    ::end::
  }

  public function toString(): String {
    return Anna.inspect(this);
  }

}';

  public static function generate(v0: TypeSpec): String {
    return {
      switch([v0]) {
        case [{fields: fields, class_name: class_name, package_name: package_name}]:
          var template: Template = new Template(classTemplate);

          var constructor_args: Array<String> = ArrayEnum.into(fields, [], function(fieldSpec: FieldSpec): String {
            return {
              '${fieldSpec.name.value}: ${fieldSpec.type.value}';
            }
          });

          template.execute({
            class_name: class_name.value,
            package_name: package_name.value,
            fields: fields,
            constructor_args: ArrayEnum.join(constructor_args, ', ')
          });
      }
    }
  }

}