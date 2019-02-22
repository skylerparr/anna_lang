# Anna Lang

A fully functional programming language that will eventually transpile
to multiple language targets. Currently just C++.

# Current Syntax

```
defmodule Foo.Bar.Sample do

  @spec(sum, {Int, Int}, Int)
  def sum(a, b) do
    a + b
  end

  @spec(hello_world, nil, String)
  def hello_world() do
    "hello world"
  end
  
  # Types can be inferred too
  def test() do
    "works"
  end
end
```

# Language features (in progress)

- [x] Modules
- [x] Functions
- [x] Basic types: Arrays, Maps, Strings, Ints, Floats, Atoms
- [x] Type checking
- [ ] Function Overloading
- [ ] Custom Types
- [ ] Function head pattern matching
- [ ] Pattern matching on assignment
- [ ] Macros
- [ ] Tail call recursion
- [ ] Syntax for Linked Lists 
- [ ] Actor Model
- [ ] Integration with target language 
- [ ] Release compilation for various targets