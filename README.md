# Anna Lang

A fully functional programming language that will eventually transpile
to multiple language targets. Currently just C++.

Installation Notes:
===================
I'm assuming you already have your system setup to compile
C++ files on your desired OS and have haxe 4.1.3 installed

First you will need the correct haxelibs.
First grab hxcpp from haxelib
`haxelib install hxcpp`
next you need a library called sepia, we can just clone it 
into this directory and set the dev directory for haxelib.
```
$ git clone git@github.com:skylerparr/sepia.git
$ haxelib dev sepia sepia/src
```
Next we'll need hxbert
```
$ git clone git@github.com:skylerparr/hxbert.git
$ haxelib dev hxbert hxbert/src
```
Lastly we need a specific branch of hscript-plus
```
$ git clone --branch hf_fork git@github.com:skylerparr/hscript-plus.git
$ haxelib dev hscript-plus hscript-plus
```
Now we're ready to build and run:
```
$ haxe build-static.hxml && ./anna-static/StandaloneMain-debug
```
If all goes well, you'll see the interactive anna console.

Please report bugs :)

TODO:
=====
- [x] Make scheduler an interface and create an implementation for each target type (cpp, java, etc)
- [x] create a wrapper for invoking the scheduler's update loop function
- [ ] Create a logger that receives messages to create a single thread for logging. Make it a macro
so that I can disable the different log levels and save the line number
- [ ] create a way to pass which scheduler to use
- [ ] html5 can use web workers as long as the main thread is doing the message passing
- [x] we can break anna_lang into multiple different projects now. Anna_vm, anna_lang (the macros), interactive anna (ia)
- [x] If I use the generic single threaded scheduler, I can use Anna vm for the macro compiler
- [ ] create a way to pass a tuple of AST to the compiler and have it generate anna_lang code.
- [ ] create a way to pass anna_lang haxe AST to convert to anna_lang AST
- [ ] Creating the anna interpreter will allow me to move to haxe 4. Since we won't be tied to cppia so much.
- [ ] need to dynamically generate the hxml for automatically adding class paths for non-sepia projects
- [x] Need to add a macro to ensure that all project files are included in the build 
- [ ] need to update the sepia library to be a bit more like a compiler and not a CLI
- [x] create a configuration method for adding applications to a project
- [x] after creating a configuration method, that leads into external libraries to be loaded or compiled in
- [ ] create a dependency graph and create an intelligent way to compile cppia libraries without compiling the entire binary

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

