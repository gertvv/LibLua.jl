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

# --- Macros listed under "some useful macros" ---

#define lua_getextraspace(L)    ((void *)((char *)(L) - LUA_EXTRASPACE))

# --- functions from lauxlib.h ---

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