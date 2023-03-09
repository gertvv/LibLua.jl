# --- Access functions (stack -> C) ---

"""
    lua_type(L, index)

Return the LuaType of the value in the given valid index, or TNone for a
non-valid but acceptable index.
"""
function lua_type(L::Ptr{LuaState}, index)::LuaType
    return LuaType(ccall((:lua_type, liblua), Cint, (Ptr{LuaState}, Cint), L, index))
end

"""
    (value, isnum) = lua_tonumberx(L, index)

Convert the Lua value at the given index to a Float64. The Lua value must be a
number or a string convertible to a number; otherwise, 0 is returned.

The boolean isnum indicates whether the operation succeeded.
"""
function lua_tonumberx(L::Ptr{LuaState}, index)::Tuple{Float64,Bool}
    isnum = Ref{Cint}(0)
    value = ccall((:lua_tonumberx, liblua), Cdouble, (Ptr{LuaState}, Cint, Ptr{Cint}), L, index, isnum)
    return (value, Bool(isnum[]))
end

"""
    lua_tonumber(L, index)

Convert the Lua value at the given index to a Float64. The Lua value must be a
number or a string convertible to a number; otherwise, 0 is returned.
"""
function lua_tonumber(L::Ptr{LuaState}, index)::Float64
    return ccall((:lua_tonumberx, liblua), Cdouble, (Ptr{LuaState}, Cint, Ptr{Cint}), L, index, C_NULL)
end

"""
    (value, isnum) = lua_tointegerx(L, index)

Convert the Lua value at the given index to a Int64. The Lua value must be an
integer, or a number or string convertible to an integer; otherwise, 0 is
returned. 

The boolean isnum indicates whether the operation succeeded.
"""
function lua_tointegerx(L::Ptr{LuaState}, index)::Tuple{Int64, Bool}
    isnum = Ref{Cint}(0)
    value = ccall((:lua_tointegerx, liblua), Int64, (Ptr{LuaState}, Cint, Ptr{Cint}), L, index, isnum)
    return (value, Bool(isnum[]))
end

"""
    lua_tointeger(L, index)

Convert the Lua value at the given index to a Int64. The Lua value must be an
integer, or a number or string convertible to an integer; otherwise, 0 is
returned. 
"""
function lua_tointeger(L::Ptr{LuaState}, index)::Int64
    return ccall((:lua_tointegerx, liblua), Int64, (Ptr{LuaState}, Cint, Ptr{Cint}), L, index, C_NULL)
end

"""
    lua_toboolean(L, index)

Convert the Lua value at the given index to a C boolean value (0 or 1). Like
all tests in Lua, lua_toboolean returns true for any Lua value different from
false and nil; otherwise it returns false.
"""
function lua_toboolean(L::Ptr{LuaState}, index)::Bool
    return Bool(ccall((:lua_toboolean, liblua), Cint, (Ptr{LuaState}, Cint), L, index))
end

"""
    (value, len) = lua_tolstring(L, index)

Convert the Lua value at the given index to a C string. The Lua value must be a
string or a number; otherwise, the function returns NULL. If the value is a
number, then this also changes the actual value in the stack to a string. (This
change confuses lua_next when applied to keys during a table traversal.)

Returns a pointer to a string inside the Lua state. This string always has a
zero ('\0') after its last character (as in C), but can contain other zeros in
its body. 

len indicates the string length.
"""
function lua_tolstring(L::Ptr{LuaState}, index)::Tuple{String,Csize_t}
    len = Ref{Csize_t}(0)
    value = ccall((:lua_tolstring, liblua), Ptr{Int8}, (Ptr{LuaState}, Cint, Ref{Csize_t}), L, index, len)
    return (unsafe_string(value, len[]), len[])
end

"""
    lua_tostring(L, index)

Convert the Lua value at the given index to a C string. The Lua value must be a
string or a number; otherwise, the function returns NULL. If the value is a
number, then this also changes the actual value in the stack to a string. (This
change confuses lua_next when applied to keys during a table traversal.)

Returns a pointer to a string inside the Lua state. This string always has a
zero ('\0') after its last character (as in C), but can contain other zeros in
its body. 
"""
function lua_tostring(L::Ptr{LuaState}, index)::String
    return unsafe_string(ccall((:lua_tolstring, liblua), Cstring, (Ptr{LuaState}, Cint, Ptr{Csize_t}), L, index, C_NULL))
end

"""
    lua_tocfunction(L, index)

Convert a value at the given index to a C function. That value must be a C
function; otherwise, return NULL. 
"""
function lua_tocfunction(L::Ptr{LuaState}, index)::Ptr{Cvoid}
    return ccall((:lua_tocfunction, liblua), Ptr{Cvoid}, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_touserdata(L, index)

If the value at the given index is a full userdata, return its memory-block
address. If the value is a light userdata, return its value (a pointer).
Otherwise, return NULL. 
"""
function lua_touserdata(L::Ptr{LuaState}, index)::Ptr{Cvoid}
    return ccall((:lua_touserdata, liblua), Ptr{Cvoid}, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_tothread(L, index)

Convert the value at the given index to a Lua thread. This value must be a
thread; otherwise, the function returns NULL. 
"""
function lua_tothread(L::Ptr{LuaState}, index)::Ptr{LuaState}
    return ccall((:lua_tothread, liblua), Ptr{LuaState}, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_topointer(L, index)

Convert the value at the given index to a generic C pointer (void*). The value
can be a userdata, a table, a thread, a string, or a function; otherwise, return
NULL. Different objects will give different pointers. There is no way to convert
the pointer back to its original value.

Typically this function is used only for hashing and debug information. 
"""
function lua_topointer(L::Ptr{LuaState}, index)::Ptr{Cvoid}
    return ccall((:lua_topointer, liblua), Ptr{Cvoid}, (Ptr{LuaState}, Cint), L, index)
end

# --- Push functions (C -> stack) ---

"""
    lua_pushnil(L)

Push a nil value onto the stack.
"""
function lua_pushnil(L::Ptr{LuaState})::Nothing
    ccall((:lua_pushnil, liblua), Cvoid, (Ptr{LuaState},), L)
end

"""
    lua_pushnumber(L, n)

Push a float with value n onto the stack.
"""
function lua_pushnumber(L::Ptr{LuaState}, n)::Nothing
    ccall((:lua_pushnumber, liblua), Cvoid, (Ptr{LuaState}, Cdouble), L, n)
end

"""
    lua_pushinteger(L, n)

Push an integer with value n onto the stack. 
"""
function lua_pushinteger(L::Ptr{LuaState}, n)::Nothing
    ccall((:lua_pushinteger, liblua), Cvoid, (Ptr{LuaState}, Int64), L, n)
end

"""
    lua_pushlstring(L, s, len)

Push the string s with size len onto the stack. Lua will make or reuse an
internal copy of the given string, so the memory at s can be freed or reused
immediately after the function returns. The string can contain any binary data,
including embedded zeros.

Return a pointer to the internal copy of the string. 
"""
function lua_pushlstring(L::Ptr{LuaState}, s, len)::Cstring
    return ccall((:lua_pushlstring, liblua), Cstring, (Ptr{LuaState}, Cstring, Csize_t), L, s, len)
end

"""
    lua_pushstring(L, s)

Push the zero-terminated string s onto the stack. Lua will make or reuse an
internal copy of the given string, so the memory at s can be freed or reused
immediately after the function returns.

Returns a pointer to the internal copy of the string.

If s is NULL, pushes nil and returns NULL.
"""
function lua_pushstring(L::Ptr{LuaState}, s)::Cstring
    return ccall((:lua_pushstring, liblua), Cstring, (Ptr{LuaState}, Cstring), L, s)
end

"""
    lua_pushcclosure(L, fn, n)

Push a new C closure onto the stack. This function receives a pointer to a C
function and pushes onto the stack a Lua value of type function that, when
called, invokes the corresponding C function. The parameter n tells how many
upvalues this function will have.

When a C function is created, it is possible to associate some values with it,
the so called upvalues; these upvalues are then accessible to the function
whenever it is called. This association is called a C closure. To create a C
closure, first the initial values for its upvalues must be pushed onto the
stack. (When there are multiple upvalues, the first value is pushed first.) Then
lua_pushcclosure is called to create and push the C function onto the stack,
with the argument n telling how many values will be associated with the
function. lua_pushcclosure also pops these values from the stack.

The maximum value for n is 255.

When n is zero, this function creates a light C function, which is just a
pointer to the C function. In that case, it never raises a memory error.
"""
function lua_pushcclosure(L::Ptr{LuaState}, fn, n)::Nothing
    ccall((:lua_pushcclosure, liblua), Cvoid, (Ptr{LuaState}, Ptr{Cvoid}, Cint), L, fn, n)
end

"""
    lua_pushcfunction(L, fn)

Push a C function onto the stack. This function is equivalent to
lua_pushcclosure with no upvalues.
"""
function lua_pushcfunction(L::Ptr{LuaState}, fn)::Nothing
    lua_pushcclosure(L, fn, 0)
end

"""
    lua_pushboolean(L, b)

Push a boolean value with value b onto the stack.
"""
function lua_pushboolean(L::Ptr{LuaState}, b)::Nothing
    ccall((:lua_pushboolean, liblua), Cvoid, (Ptr{LuaState}, Cint), L, b)
end

"""
    lua_pushlightuserdata(L, p)

Push a light userdata onto the stack.

Userdata represent C values in Lua. A light userdata represents a pointer, a
void*. It is a value (like a number): you do not create it, it has no individual
metatable, and it is not collected (as it was never created). A light userdata
is equal to "any" light userdata with the same C address. 
"""
function lua_pushlightuserdata(L::Ptr{LuaState}, p)::Nothing
    ccall((:lua_pushlightuserdata, liblua), Cvoid, (Ptr{LuaState}, Ptr{Cvoid}), L, p)
end

"""
    lua_pushthread(L)

Push the thread represented by L onto the stack. Return true if this thread is
the main thread of its state.
"""
function lua_pushthread(L::Ptr{LuaState})::Bool
    return Bool(ccall((:lua_pushthread, liblua), Cint, (Ptr{LuaState},), L))
end

# --- Macros listed under "some useful macros" ---

"""
    lua_register(L, name, fn)

Set the C function fn as the new value of global name.
"""
function lua_register(L::Ptr{LuaState}, name, fn::Ptr{Cvoid})::Nothing
    lua_pushcfunction(L, fn)
    lua_setglobal(L, name)
end