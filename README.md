# Anna Lang

A fully functional programming language that will eventually transpile
to multiple language targets. Currently just C++.

# Current Syntax

```
  @alias vm.Process;
  @alias vm.Kernel;

  @def start([Int], {
    print(get_string(), return_num(get_one()), get_two());
    result = @native Kernel.add(get_one(), get_two());
    @native IO.inspect(result);
    result = @native Kernel.add(result, get_one());
    @native IO.inspect(result);
    one_hundred = "100";
    pid = @native Process.self();
    counter = @native Kernel.add(23, 491);
    @native IO.inspect(counter);
    @native IO.inspect(null);
    @native IO.inspect(pid);
    p3 = print();
    p2 = print("hello world", 90210, counter);
    @native IO.inspect(p2);
    @native IO.inspect([@_"ok", "all correct"]);
    @native IO.inspect({@_"ok"; "all correct";});
    map = cast(@native IO.inspect([ @_"ok" => "all", @_'error' => "correct"]), MMap);
    @native IO.inspect(p3);
    @native IO.inspect(map);
//    @native IO.inspect("waiting...");
    fun = @fn {
      ([{Int: 10}, [Atom]] => {
        @native IO.inspect("got ten");
        @native IO.inspect(map);
        @_"ok";
      });
      ([{Int: 0}, [Atom]] => {
        @native IO.inspect("got zero");
        @native IO.inspect(map);
        @_"ok";
      });
      ([{Int: num}, [Atom]] => {
        @native IO.inspect(num);
        @_"ok";
      });
    }
    result = fun(map);
//    @native IO.inspect(result);
//    @native IO.inspect("waiting for data");
//    received = @native Kernel.receive(fun);
//    @native IO.inspect("received:");
//    @native IO.inspect(received);

//    print(result);
//    received = @native Kernel.receive(@fn{
//      ([{String: foo}, [Dynamic]] => {
//        value;
//      });
//    });
//    @native IO.inspect("received:");
//    @native IO.inspect(received);
    foo(p3);
    foo(p2);
    bar(map);
//    @native IO.inspect({ok: "foob"}); //keyword list
    print(pid);
  });

  @def print([Int], {
    @native IO.inspect('print with no args');
    arg1 = "100";
    pid = @native Process.self();
    199.909;
    arg2 = 100;
    @_"money";
    [@_"tuple"];
    list = {@_"list"; @_"Smelly"; @_"Ellie";};
    arg3 = 300;
    arg4 = arg3;
    @native IO.inspect(arg3);
    @native IO.inspect(arg4);
    @native IO.inspect(list);
    @native IO.inspect({});
    @native IO.inspect("returning");
    arg4;
  });

  @def print({String: value, Int: count, Int: test}, [Int], {
    @native IO.inspect('print with 2 args');
    @native IO.inspect(value);
    @native IO.inspect(count);
    @native IO.inspect(test);
  });

  @def print({String: string}, [String], {
    @native IO.inspect(string);
    string;
  });

  @def print({Atom: val}, [Atom], {
    @native IO.inspect(val);
    val;
  });

  @def print({Process: process}, [Atom], {
    @native IO.inspect(process);
    @_'ok';
  });

  @def foo({Int: value}, [String], {
    @native IO.inspect("In foo");
    @native IO.inspect(value);
  });

  @def bar({MMap: map}, [String], {
    @native IO.inspect("in bar");
    @native IO.inspect(map);
  });

  @def get_string([String], {
    "hello world";
  });

  @def get_one([Int], {
    1;
  });

  @def get_two([Int], {
    2;
  });

  @def return_num({Int: number}, [Int], {
    number;
  });

  @def get_atom([Atom], {
    @_'ok';
  });
```

TODO:
=====
- [ ] create a way to pass which scheduler to use
- [ ] create a way to pass a tuple of AST to the compiler and have it generate anna_lang code.
- [ ] create a way to pass anna_lang haxe AST to convert to anna_lang AST

# BUGS!

- [ ] user defined type not being resolved correct in anonymous functions
- [ ] Investigate why this is throwing a runtime exception
```
    Kernel.cond(c, @fn {
      [{Int: -1}] => {
        '#' => color = color;
        color = Str.concat('0x', color);
        Str.string_to_int(color);
      };
      [{Int: val}] => {
        val;
      };
    });
``` 
Likely it's an issue with the anonymous function pattern matching using a negative


# Language features (in progress)

- [x] Modules
- [x] Interfaces
- [x] Functions
- [x] Basic types: Arrays, Maps, Lists, Tuples, Strings, Ints, Floats, Atoms
- [x] Type checking. Type inference with casts
- [x] Anonymous functions
- [x] Keyword Lists
- [x] Function Overloading
- [x] Custom Types
- [x] Function head pattern matching
- [x] Pattern matching on assignment
- [ ] Macros
- [x] Tail call recursion
- [x] Actor Model
- [x] Send messages to other processes
- [x] Integration with target language *there's bugs in the haxe Stdlib :( 
- [ ] Release compilation for various targets
- [ ] Standard library

# NOTES TO SELF

- Create a smarter logging system. Like:
  - log once
  - log every n secs/mins/etc. 
    - Will only log if log regex is logged N times within a given period of time

