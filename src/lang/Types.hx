package lang;
enum Types {
    ATOM;
}

typedef Atom = {
    value: String,
    __type__: Types
}