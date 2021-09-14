
--[[
    MIT license

    Copyright (c) 2021 Daniele Gurizzan

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local array = {
    _VERSION = '0.9',
    _DESCRIPTION = [[
        A useful collection of methods to work with tables in an array fashion.
    ]],
    _URL = ''
}
array.__index = array

-- deepcopy helper
local function dch(cache, copying, current)
    -- kinda out of the array domain, but allows the array to contain hashes
    for key, value in pairs(copying) do
        if type(value) == 'table' and (not cache[tostring(value)]) then
            cache[tostring(value)] = true
            current[key] = dch(cache, value, {})
        else
            current[key] = value
        end
    end

    return current
end

-- blend(ing) helper
local function mh(a, b, comp)
    local bnum = #b
    for i = 1, bnum do
        local current = b[i]
        local inserted = false
        local j = 0

        while not inserted and j < #a do
            j = j + 1
            inserted = comp(current, a[j])
            if inserted then table.insert(a, j, current) end
        end

        if not inserted then table.insert(a, current) end
    end
end

-- simplest array creation
function array.new(value, length)
    local a = {}
    if value ~= nil and length ~= nil then
        array.init(a, value, length)
    end
    setmetatable(a, array)
    return a
end

-- create a new array from a set of values
function array.from(...)
    local a = { ... }
    setmetatable(a, array)
    return a
end

-- shallow-copy
function array.copy(a)
    local b = array.new()
    for i = 1, #a do 
        b[i] = a[i]
    end
    return b
end

-- deep-copy (clones table items and subtables)
function array.deepcopy(a)
    local b = array.new()
    local cache = { [tostring(b)] = true }

    return dch(cache, a, b)
end

-- fill an array
function array.init(a, value, length)
    local func = type(value) == 'function'
    for i = 1, length do table.insert(a, func and value(i) or value) end
end

-- push any number of items in the array
function array.pushback(a, ...)
    local values = { ... }
    for i = 1, #values do
        if values[i] ~= nil then
            table.insert(a, values[i])
        end
    end
end

function array.pushfront(a, ...)
    local values = { ... }
    for i = 1, #values do
        if values[i] ~= nil then
            table.insert(a, 1, values[i])
        end
    end
end

-- pop any number of items from the array
function array.popback(a, num)
    if #a > 0 then
        if num then
            local n = math.max(1, math.min(num, #a))
            local removed = {}

            for i = 1, n do
                table.insert(removed, table.remove(a))
            end

            return unpack(removed)
        else
            table.remove(a)
        end
    end
end

function array.popfront(a, num)
    if #a > 0 then
        if num then
            local n = math.max(1, math.min(num, #a))
            local removed = {}

            for i = 1, n do
                table.insert(removed, table.remove(a, 1))
            end
            
            return unpack(removed)
        else
            return table.remove(a, 1)
        end
    end
end

-- shorthands to get the first and the last item
function array.first(a) 
    return a[1] 
end

function array.last(a) 
    return a[#a] 
end

-- get item(s) which match a condition
function array.find(a, comp, from, ...)
    local pos = false
    local afrom = from and math.max(1, math.min(#a, from > 0 and from or #a+from+1)) or 1
    local to = from and (from > 0 and #a or 1) or #a
    local var = from and (from > 0 and 1 or -1) or 1

    if type(comp) == 'function' then
        for i = afrom, to, var do
            if (not pos) and comp(a[i], ...) then
                pos = i
            end
        end
    else
        for i = afrom, to, var do
            if (not pos) and a[i] == comp then
                pos = i
            end
        end
    end

    return pos
end

function array.findall(a, comp, ...)
    local len = #a
    local pos = {}

    if type(comp) == 'function' then
        for i = 1, len do
            if comp(a[i], ...) then
                table.insert(pos, i)
            end
        end
    else
        for i = 1, len do
            if a[i] == comp then
                table.insert(pos, i)
            end
        end
    end

    return unpack(pos)
end

-- extraction
function array.remove(a, from, to)
    local afrom = from and math.max(1, math.min(#a, from < 0 and #a + from or from)) or 1
    local ato = to and math.max(afrom, math.min(#a, to < 0 and #a + to or to)) or #a
    local num = math.min(ato - afrom + 1, #a)
    local removed = {}

    for i = 1, num do
        table.insert(removed, table.remove(a, afrom))
    end

    return unpack(removed)
end

function array.subset(a, from, to)
    local afrom = from and math.max(1, math.min(#a, from < 0 and #a + from or from)) or 1
    local ato = to and math.max(afrom, math.min(#a, to < 0 and #a + to or to)) or #a
    local delta = ato - afrom
    local set = {}

    for i = 0, delta do
        table.insert(set, a[afrom + i])
    end

    return unpack(set)
end

-- subdivide in arbitrary slices
function array.split(a, ...)
    local slices = {}
    local indexes = { ... }
    local previous = 0

    for i = 1, #indexes do
        local index = indexes[i]

        if index ~= nil then
            local amount = index - previous

            if amount > 0 then
                table.insert(slices, array.from(array.remove(a, 1, amount)))
            end

            previous = index
        end
    end

    return unpack(slices)
end

function array.slices(a, ...)
    local b = array.copy(a)
    local s = { b:split(...) }
    table.insert(s, b)
    return unpack(s)
end

-- joining
function array.append(a, ...)
    if a == nil then a = array.new() end
    local other = { ... }

    for i = 1, #other do 
        if other[i] ~= nil then
            a:pushback(unpack(other[i]))
        end
    end
end

function array.union(a, ...)
    local u = array.copy(a)
    u:merge(...)
    return u
end

-- joining, but smarter
function array.merge(a, comp, ...)
    table.sort(a, comp)
    local other = { ... }

    for i = 1, #other do 
        if other[i] ~= nil then
            mh(a, other[i], comp)
        end
    end
end

function array.fusion(a, comp, ...)
    local b = array.copy(a)
    b:merge(comp, ...)
    return b
end

-- get a random item
function array.random(a, from, to)
    local afrom = from and math.max(1, math.min(#a, from)) or 1
    local ato = to and math.max(from, math.min(#a, to)) or #a
    return a[math.random(afrom, ato)]
end

-- shuffle items
function array.shuffle(a)
    local anum = #a

    for i = 1, anum do
        local swapindex = math.random(1, anum)
        local temp = a[swapindex]
        a[swapindex] = a[i]
        a[i] = temp
    end
end

function array.shuffled(a)
    local b = array.copy(a)
    b:shuffle()
    return b
end

-- invert the order of items
function array.reverse(a)
    local num = #a
    local swaps = math.floor(num * 0.5)

    for i = 1, swaps do
        local opposite = num-(i-1)
        local temp = a[opposite]
        a[opposite] = a[i]
        a[i] = temp
    end
end

function array.reversed(a)
    local r = array.copy(a)
    r:reverse()
    return r
end

-- count the number of items that match a condition
function array.count(a, comp)
    return #{ array.findall(a, comp) }
end

-- get the string representation
function array.tostring(a, separator, tostring_function, add_index, brackets)
    local out = ''
    local sep = separator or ', '
    local pf = tostring_function or tostring

    for i = 1, #a do
        out = out .. (add_index and (i .. ': ') or '') .. pf(a[i]) .. (i < #a and sep or '')
    end

    return (brackets and '[' .. out .. ']' or out)
end

-- print on console
function array.print(a, separator, tostring_function, show_index)
    print(array.tostring(a, separator, tostring_function, show_index, true))
end

return array