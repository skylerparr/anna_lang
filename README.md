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
- [ ] Make scheduler an interface and create an implementation for each target type (cpp, java, etc)
- [ ] create a wrapper for invoking the scheduler's update loop function
- [ ] Create a logger that receives messages to create a single thread for logging. Make it a macro
so that I can disable the different log levels and save the line number
- [ ] create a way to pass which scheduler to use
- [ ] html5 can use web workers as long as the main thread is doing the message passing
- [x] we can break anna_lang into multiple different projects now. Anna_vm, anna_lang (the macros), interactive anna (ia)
- [ ] If I use the generic single threaded scheduler, I can use Anna vm for the macro compiler
- [ ] create a way to pass a tuple of AST to the compiler and have it generate anna_lang code.
- [ ] create a way to pass anna_lang haxe AST to convert to anna_lang AST
- [ ] Creating the anna interpreter will allow me to move to haxe 4. Since we won't be tied to cppia so much.
- [ ] need to dynamically generate the hxml for automatically adding class paths for non-sepia projects
- [x] Need to add a macro to ensure that all project files are included in the build 
- [ ] need to update the sepia library to be a bit more like a compiler and not a CLI
- [x] create a configuration method for adding applications to a project
- [x] after creating a configuration method, that leads into external libraries to be loaded or compiled in
- [] create a dependency graph and create an intelligent way to compile cppia libraries without compiling the entire binary

# Language features (in progress)

- [ ] Modules
- [x] Functions
- [x] Basic types: Arrays, Maps, Lists, Tuples, Strings, Ints, Floats, Atoms
- [ ] Type checking (In progress)
- [x] Anonymous functions
- [ ] Keyword Lists
- [x] Function Overloading
- [ ] Custom Types
- [x] Function head pattern matching
- [ ] Pattern matching on assignment
- [ ] Macros
- [x] Tail call recursion
- [x] Actor Model
- [x] Send messages to other processes
- [ ] Integration with target language
- [ ] Release compilation for various targets
- [ ] Standard library