# array
A useful collection of methods to work with Lua tables in an array fashion.

## usage
```lua
array = require 'array'
```
This library features OOP as well:
```lua
a = {1,2,3,4} -- a simple table
b = array.from(1,2,3,4) -- an array table

array.print(a) -- output: [1,2,3,4]
b:print() -- output: [1,2,3,4]
```

## functions
### creation
#### array.new([value, length])

Creates a empty array and optionally initialises it(see array.init below to learn more).
```lua
-- create an array containing the english alphabet
a = array.new(function(index) 
  return string.char(64 + index) 
  end, 26)
  
a:print() -- output: [A,B,C,D,E,F,G,...,Z]
```
Note: in this documentation "array" refers to a table with the array metatable assigned to it. All functions are able to work with pure tables.

#### array.from(...)

Creates an array and populates it with arguments' values.
```lua
array.from('pizza','ice cream','toast'):print() -- output: [pizza, ice cream, toast]
```

### basic

#### array.tostring(a[, separator, tostring_function, add_index, brackets])

Returns a customizable string representation of a. The argument separator allows to specify a string to separate items (defaults to ", "); tostring_function can be used to print tables' content, Lua's tostring(). add_index includes "index number: " before every item (defaults to false)

#### array.copy(a)

Produces a shallow copy of a, meaning that table items are not cloned and modification will affect the original and its copies.
```lua
a = array.from({name = 'John', age = 19}, {name = 'Jennifer', age = 20})
b = a:copy()
a[1].age = 20

function persontostr(person) return string.format('name: %s age: %u', person.name, person.age) end

a:print(nil, persontostr) -- output: [name: John age: 20, name: Jennifer age: 20]
b:print(nil, persontostr) -- output: [name: John age: 20, name: Jennifer age: 20], b got modified
```
Remember: All functions which generate new array(s) transforming one use this method.

#### array.deepcopy(a)

Produces a deep copy of a: by traversing subtables, this function returns a fully independant clone.
```lua
a = array.from({60},{70},{80})
b = a:deepcopy()
b[2][1] = 72

a:print(...) -- output: [{60}, {70}, {80}], a was not affected
b:print(...) -- output: [{60}, {72}, {80}]
```

#### array.init(a, value, length)

Assigns the value "value", to the first length items of the array a. The argument value can be a function which takes the item's index as argument, to return its value.
``` lua
a, b = {}, {}
array.init(a, 1,4) -- result: {1,1,1,1}
array.init(b, function(i) return 1 end, 4) -- result: {1,1,1,1}
```
Note: remember to omit "a" when you use OOP.
