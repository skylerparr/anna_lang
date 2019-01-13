package lang;
import haxe.ds.ObjectMap;
enum Types {
    ATOM;
    TUPLE;
    LIST;
    MAP;
}
typedef Tuple = {
    value: Array<Dynamic>,
    type: Types
}

typedef Atom = {
    value: String,
    type: Types
}

typedef LinkedList = {
    value: List<Dynamic>,
    type: Types
}

typedef MatchStringMap = {
    value: haxe.ds.StringMap<Dynamic>,
    type: Types
}

typedef MatchObjectMap = {
    value: ObjectMap<Dynamic, Dynamic>,
    type: Types
}