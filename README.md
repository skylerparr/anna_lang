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

=======

TODO:
=====
- [ ] create a way to pass which scheduler to use
- [ ] create a way to pass a tuple of AST to the compiler and have it generate anna_lang code.
- [ ] create a way to pass anna_lang haxe AST to convert to anna_lang AST

# BUGS!

- [ ] user defined type not being resolved correct in anonymous functions

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

