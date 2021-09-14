# array
A useful collection of methods to work with Lua tables in an array fashion.

## usage
```lua
array = require 'array'
```
This library features OOP as well:
```lua
a = {1, 2, 3, 4} -- a simple table
b = array.from(1, 2, 3, 4) -- an array table

array.print(a) -- output: [1, 2, 3, 4]
b:print() -- output: [1, 2, 3, 4]
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
  
a:print() -- output: [A, B, C, D, E, F, G, ..., Z]
```
Note: in this documentation "array" refers to a table with the array metatable assigned to it. All functions are able to work with pure tables.

#### array.from(...)

Creates an array and populates it with arguments' values.
```lua
array.from('pizza', 'ice cream', 'toast'):print() -- output: [pizza, ice cream, toast]
```

### basic
#### array.tostring(a[, separator, tostring_function, add_index, brackets])

Returns a customizable string representation of a. The argument separator allows to specify a string to separate items (defaults to ", "); tostring_function can be used to print tables' content, where Lua's tostring() is not enough. add_index includes "index number: " before every item, its not done by default, the same goes for the  addition of square brackets to enclose the array's content (brackets argument).
```lua
a = array.from(1, 2, 3)

a:tostring() -- "1, 2, 3"
a:tostring(nil, nil, true, true) -- "[1: 1, 2: 2, 3: 3]"
a:tostring(nil, function(item) return string.char(96 + item) end) -- "a, b, c"
```
Note: remember to omit "a" when you use OOP.

#### array.print(a[, separator, tostring_function, show_index])

This is a shorthand for print(array.tostring(...)), except brackets are always included.
```lua
array.from('Hey', 'There'):print() -- output: [Hey, There]
```

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
a = array.from({60}, {70}, {80})
b = a:deepcopy()
b[2][1] = 72

a:print(...) -- output: [{60}, {70}, {80}], a was not affected
b:print(...) -- output: [{60}, {72}, {80}]
```

#### array.init(a, value, length)

Assigns the value "value", to the first length items of the array a. The argument value can be a function which takes the item's index as argument, to return its value.
``` lua
a, b = {}, {}
array.init(a, 1, 4) -- result: {1, 1, 1, 1}
array.init(b, function(i) return 1 end, 4) -- result: {1, 1, 1, 1}
```

#### array.pushback(a, ...)

Inserts any number of items in a, appending them to its end.
``` lua
a = array.new()
array.pushback(a, 3, 5, 7)
array.print(a) -- output: [3, 5, 7]
```

#### array.pushfront(a, ...)

Inserts any number of items in a, appending them to its start.
``` lua
a = array.new()
array.pushfront(a, 3, 5, 7)
array.print(a) -- output: [7, 5, 3] they appear backwards!
```

#### array.popback(a[, num])

Removes the last num items from a, or just one if not specified. num is clamped between 1 and #a.
``` lua
a = array.from(2, 4, 6)
third, second, first = a:popback(3) -- 6, 4, 2
print(a:popback(6000)) -- output: nil
```

#### array.popfront(a[, num])

Removes the first num items from a, or just one if not specified.
``` lua
a = array.from(2, 4, 6)
first, second, third = a:popfront(3) -- 2, 4, 6
```

#### array.first(a)

Simply returns the first item.
``` lua
array.first({4, 1, 7}) -- result: 4
```

#### array.last(a)

Returns the last item.
``` lua
array.first({99, 34, 12}) -- result: 12
```

#### array.remove(a[, from, to])

Allows to remove a range of items from a, indexes "from" and "to" are inclusive and represent the first and the last items in the range. You can provide negative values as in string.sub to count from the end of the array. from and to default respectively to 1 and #a. For single-item removals table.remove is suggested.

``` lua
a = {20, 21, 22, 23, 24}

array.remove(3) -- returns: 22, 23, 24
array.remove() -- returns: 20, 21 used like this, remove acts like a clear function

b = { array.remove({1, 2}, 2) } -- b: {2} if you want to collect removed items 
```

#### array.subset(a[, from, to])

Does pretty much the same as remove, but it does not remove selected items from a.

#### array.find(a, comp[, from, ...])

Returns the index of the first item that matches a condition. comp can be a function which takes the value of the current item and returns wheter it matches the condition, or simply the exact value to search for. The additional arguments ... are passed to comp when it is a function. Last but no least, "from" allows to choose where the search should start, accepts negative values and by default is 1.

``` lua
a = {2, 3, 4, 3, 2}

array.find(a, 3) -- returns: 2
array.find(a, 3, -1) -- returns: 4
array.find(a, function(item) return item >= 5 end) -- returns: false
```

#### array.findall(a, comp[, ...])

Returns the indexes of all items that match a condition. comp accepts a function and additional arguments are passed togheter with the item.

``` lua
-- find even numbers
array.from(2, 3, 4, 5, 6):findall(function(item) return item % 2 == 0 end) -- returns: 1, 3, 5
```

### cool stuff
#### array.split(a, ...)

Given at least one index, splits a in one plus the number of indexes provided slices. The first slice will go from 1 to the first index included, the second from first index + 1 to the second index included, and so on. Remaining items will be kept in a.

``` lua
a, b, c = array.from(1, 2, 3, 4, 5):split(2, 4, 5) -- a: [1, 2] b: [3, 4] c: [5]
positive = {-2, -1, 3, 7}
negative = p:split(2) -- negative: [-2, -1]
positive:print() -- output: [3, 7]
```
Note: this function returns only new arrays, a is not returned

#### array.slices(a, ...)

This is the non-desctructive version of array.split. Returns all the slices generated by the cuts.

``` lua
a = array.from('ruby', 'saphire', 'emerald')
r, s, e = a:slices(1, 2, 3)
a:print() -- output: [ruby, saphire, emerald]
```

#### array.append(a, ...)

Appends to a items from tables given as arguments.

``` lua
a = array.from('magazine', 'theory')
b = array.from('customer', 'ladder')
a:append(b)

a:print() -- output: [magazine, theory, customer, ladder]
```

#### array.union(a, ...)

Like array.append, but "a" is not modified and a new array containing all items is returned.

#### array.merge(a, comp, ...)

Joins "a" with argument tables(...), and sorts items using the comparator function comp.

``` lua
a = array.from(4, 2, 8, 6, 0)
b = array.from(9, 7, 3, 1, 5)
a:merge(function(a, b) return a < b end, b)
-- or array.merge(a, function(a, b) return a < b end, b) remember to put the receiving array before comp!

a:print() -- output: [0, 1, 2, 3, ..., 8, 9]
```

#### array.fusion(a, comp, ...)

Non-destructive merging, returns a new array containing items from a and tables(...), sorted using comparator comp.

### misc
#### array.random(a[, from, to])

Returns a random item from a, optionally choosing between items in the range from-to. As usual from and to default to 1 and #a.

``` lua
array.random({'Yes', 'No'}) -- result: Well... I don't know :P
```

#### array.shuffle(a)

Shuffles items in a by performing random swaps.

``` lua
array.shuffle({'King', 'Queen', 'Jack'}) -- possible result: [Queen, King, Jack]
```

#### array.shuffled(a)

Returns a copy of a with items in a random order.

#### array.count(a, comp)

Returns the amount of items in a which match a condition. comp should follow the rules exposed at array.find.

``` lua
array.count({2, 4, 3, 4, 5}, 4) -- result: 2
array.count({1, 4, 4, 5}, function(item) return item % 2 == 1 end) -- result: 2
```
