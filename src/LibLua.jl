module LibLua

using Lua_jll

# This file is roughly organized into the same sections as lua.h, but not making
# any distinction between functions and macros, and also including definitions
# from lauxlib.h

@enum LuaStatus begin
    OK
    Yield
    RuntimeError
    SyntaxError
    MemoryError
    MessageHandlerError
    FileError
end

@enum LuaType begin
    TNone = -1
    TNil = 0
    TBoolean = 1
    TLightUserData = 2
    TNumber = 3
    TString = 4
    TTable = 5
    TFunction = 6
    TUserData = 7
    TThread = 8
end

@enum LuaLoadMode b t bt

mutable struct LuaState
end

# --- State manipulation ---

"""
    lua_newstate(f, ud)

Create a new independent state and return its main thread. Return NULL if the
state cannot be created (due to lack of memory). The argument f is the allocator
function; Lua will do all memory allocation for this state through this function
(see lua_Alloc). The second argument, ud, is an opaque pointer that Lua passes
to the allocator in every call.
"""
function lua_newstate(f, ud)
    return ccall((:lua_newstate, liblua), Ptr{LuaState}, (Ptr{Cvoid}, Ptr{Cvoid}), f, ud)
end

"""
    lua_close(L)

Close all active to-be-closed variables in the main thread, release all objects
in the given Lua state (calling the corresponding garbage-collection
metamethods, if any), and frees all dynamic memory used by this state.

On several platforms, you may not need to call this function, because all
resources are naturally released when the host program ends. On the other hand,
long-running programs that create multiple states, such as daemons or web
servers, will probably need to close states as soon as they are not needed. 
"""
function lua_close(L::Ptr{LuaState})::Nothing
    ccall((:lua_close, liblua), Cvoid, (Ptr{LuaState},), L)
end

"""
    lua_newthread(L)

Create a new thread, push it on the stack, and return a Lua state that
represents this new thread. The new thread returned by this function shares with
the original thread its global environment, but has an independent execution
stack.

Threads are subject to garbage collection, like any Lua object. 
"""
function lua_newthread(L::Ptr{LuaState})::Ptr{LuaState}
    return ccall((:lua_newthread, liblua), Ptr{LuaState}, (Ptr{LuaState},), L)
end

"""
    lua_resetthread(L)

Reset a thread, cleaning its call stack and closing all pending to-be-closed
variables. Returns a status: OK for no errors in the thread (either the original
error that stopped the thread or errors in closing methods), or an error status
otherwise. In case of error, leaves the error object on the top of the stack.
"""
function lua_resetthread(L::Ptr{LuaState})::LuaStatus
    return ccall((:lua_resetthread, liblua), Cint, (Ptr{LuaState},), L)
end

"""
    lua_atpanic(L, panicf)

Set a new panic function and return the old one.
"""
function lua_atpanic(L::Ptr{LuaState}, panicf::Ptr{Cvoid})::Ptr{Cvoid}
    return ccall((:lua_atpanic, liblua), Ptr{Cvoid}, (Ptr{LuaState},Ptr{Cvoid}), L, panicf)
end

"""
    lua_version(L)

Return the version number of this core.
"""
function lua_version(L::Ptr{LuaState})::Float64
    return ccall((:lua_version, liblua), Cdouble, (Ptr{LuaState},), L)
end

"""
    luaL_newstate()

Create a new Lua state. Return the new state, or NULL if there is a memory
allocation error.

It calls lua_newstate with an allocator based on the standard C allocation
functions and then sets a warning function and a panic function (see §4.4) that
print messages to the standard error output.
"""
function luaL_newstate()::Ptr{LuaState}
    return ccall((:luaL_newstate, liblua), Ptr{LuaState}, ())
end

"""
    luaL_openlibs(L)

Open all standard Lua libraries into the given state.
"""
function luaL_openlibs(L::Ptr{LuaState})::Nothing
    ccall((:luaL_openlibs, liblua), Cvoid, (Ptr{LuaState},), L)
end

# --- Basic stack manipulation ---

function lua_absindex(L::Ptr{LuaState}, index)
    return ccall((:lua_absindex, liblua), Cint, (Ptr{LuaState}, Cint), L, index)
end

# --- Access functions (stack -> C) ---

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
function lua_tolstring(L::Ptr{LuaState}, index)::Tuple{Cstring,Csize_t}
    len = Ref{Cint}(0)
    value = ccall((:lua_tolstring, liblua), Cstring, (Ptr{LuaState}, Cint, Ref{Csize_t}), L, index, len)
    return (value, len[])
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
function lua_tostring(L::Ptr{LuaState}, index)::Cstring
    return ccall((:lua_tolstring, liblua), Cstring, (Ptr{LuaState}, Cint, Ptr{Csize_t}), L, index, C_NULL)
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

# --- Comparison and arithmetic functions ---


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

# --- Get functions (Lua -> stack) ---

function lua_getglobal(L::Ptr{LuaState}, name)::LuaType
    return LuaType(ccall((:lua_getglobal, liblua), Cint, (Ptr{LuaState}, Cstring), L, name))
end

function lua_getfield(L::Ptr{LuaState}, index, k)::LuaType
    return LuaType(ccall((:lua_getfield, liblua), Cint, (Ptr{LuaState}, Cint, Cstring), L, index, k))
end

function lua_settop(L::Ptr{LuaState}, idx)::Nothing
    ccall((:lua_settop, liblua), Cvoid, (Ptr{LuaState}, Cint), L, idx)
end

function lua_rotate(L::Ptr{LuaState}, idx, n)::Nothing
    ccall((:lua_rotate, liblua), Cvoid, (Ptr{LuaState}, Cint, Cint), L, idx, n)
end

# Macros listed under "some useful macros"

function lua_pop(L::Ptr{LuaState}, n)::Nothing
    lua_settop(L, -n - 1)
end

function lua_remove(L::Ptr{LuaState}, idx)::Nothing
    lua_rotate(L, idx, -1)
    lua_pop(L, 1)
end

# --- Set functions (stack -> Lua) ---


# --- 'load' and 'call' functions (load and run Lua code) ---

# TODO: consider returning error string along with status

function luaL_loadstring(L::Ptr{LuaState}, str)::LuaStatus
    return LuaStatus(ccall((:luaL_loadstring, liblua), Cint, (Ptr{LuaState}, Cstring), L, str))
end

function luaL_loadfilex(L::Ptr{LuaState}, filename, mode::LuaLoadMode)::LuaStatus
    LuaStatus(ccall((:luaL_loadfilex, liblua), Cint, (Ptr{LuaState}, Cstring, Cstring), L, filename, String(Symbol(mode))))
end

function luaL_loadfile(L::Ptr{LuaState}, filename)::LuaStatus
    LuaStatus(ccall((:luaL_loadfilex, liblua), Cint, (Ptr{LuaState}, Cstring, Cstring), L, filename, C_NULL))
end

function lua_callk(L::Ptr{LuaState}, nargs, nresults, ctx::Cptrdiff_t, k::Ptr{Cvoid})::Nothing
    ccall((:lua_callk, liblua), Cvoid, (Ptr{LuaState}, Cint, Cint, Cptrdiff_t, Ptr{Cvoid}), L, nargs, nresults, ctx, k)
end

function lua_call(L::Ptr{LuaState}, nargs, nresults)::Nothing
    lua_callk(L, nargs, nresults, 0, C_NULL)
end

function lua_pcallk(L::Ptr{LuaState}, nargs, nresults, msgh, ctx::Cptrdiff_t, k::Ptr{Cvoid})::LuaStatus
    return LuaStatus(ccall((:lua_pcallk, liblua), Cint, (Ptr{LuaState}, Cint, Cint, Cint, Cptrdiff_t, Ptr{Cvoid}), L, nargs, nresults, msgh, ctx, k))
end

function lua_pcall(L::Ptr{LuaState}, nargs, nresults, msgh = C_NULL)::LuaStatus
    return lua_pcallk(L, nargs, nresults, msgh, 0, C_NULL)
end

# --- Coroutine functions ---


# --- Warning-related functions ---


# --- Garbage-collection function and options


# --- Miscellaneous functions ---

function lua_next(L::Ptr{LuaState}, index)
    return ccall((:lua_next, liblua), Cint, (Ptr{LuaState}, Cint), L, index)
end

export
    LuaStatus,
    LuaType,
    luaL_newstate,
    luaL_openlibs,
    luaL_loadstring,
    lua_pcall,
    lua_pushinteger,
    lua_getglobal,
    lua_tointegerx,
    lua_close

end
