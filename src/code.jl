# --- 'load' and 'call' functions (load and run Lua code) ---

"""
    lua_callk(L, nargs, nresults, ctx, k)

Behaves exactly like lua_call, but allows the called function to yield.
"""
function lua_callk(L::Ptr{LuaState}, nargs, nresults, ctx::Cptrdiff_t, k::Ptr{Cvoid})::Nothing
    ccall((:lua_callk, liblua), Cvoid, (Ptr{LuaState}, Cint, Cint, Cptrdiff_t, Ptr{Cvoid}), L, nargs, nresults, ctx, k)
end

"""
    lua_call(L, nargs, nresults)

Call a function (or a callable object).

To do a call you must use the following protocol: first, the function to be
called is pushed onto the stack; then, the arguments to the call are pushed in
direct order; that is, the first argument is pushed first. Finally you call
lua_call; nargs is the number of arguments that you pushed onto the stack. When
the function returns, all arguments and the function value are popped and the
call results are pushed onto the stack. The number of results is adjusted
to nresults, unless nresults is LUA_MULTRET. In this case, all results from the
function are pushed; Lua takes care that the returned values fit into the stack
space, but it does not ensure any extra space in the stack. The function results
are pushed onto the stack in direct order (the first result is pushed first), so
that after the call the last result is on the top of the stack.
    
Any error while calling and running the function is propagated upwards (with a
longjmp).
"""
function lua_call(L::Ptr{LuaState}, nargs, nresults)::Nothing
    lua_callk(L, nargs, nresults, 0, C_NULL)
end

"""
    lua_pcallk(L, nargs, nresults, msgh, ctx, k)

Behaves exactly like lua_pcall, except that it allows the called function to
yield.
"""
function lua_pcallk(L::Ptr{LuaState}, nargs, nresults, msgh, ctx::Cptrdiff_t, k::Ptr{Cvoid})::LuaStatus
    return LuaStatus(ccall((:lua_pcallk, liblua), Cint, (Ptr{LuaState}, Cint, Cint, Cint, Cptrdiff_t, Ptr{Cvoid}), L, nargs, nresults, msgh, ctx, k))
end

"""
    lua_pcall(L, nargs, nresults[, msgh])

Call a function (or a callable object) in protected mode.

If there are no errors during the call, lua_pcall behaves exactly like lua_call.
However, if there is any error, lua_pcall catches it, pushes a single value on
the stack (the error object), and returns an error code. Like lua_call,
lua_pcall always removes the function and its arguments from the stack.
    
If msgh is 0, then the error object returned on the stack is exactly the
original error object. Otherwise, msgh is the stack index of a message handler.
This index cannot be a pseudo-index. In case of runtime errors, this handler
will be called with the error object and its return value will be the object
returned on the stack by lua_pcall.
    
Typically, the message handler is used to add more debug information to the
error object, such as a stack traceback. Such information cannot be gathered
after the return of lua_pcall, since by then the stack has unwound.

May return OK, RuntimeError, MemoryError, or MessageHandlerError.
"""
function lua_pcall(L::Ptr{LuaState}, nargs, nresults, msgh = C_NULL)::LuaStatus
    return lua_pcallk(L, nargs, nresults, msgh, 0, C_NULL)
end

# TODO: consider returning error string along with status
"""
    lua_load(L, reader, data, chunkName, mode)

Load a Lua chunk without running it. If there are no errors, push the compiled
chunk as a Lua function on top of the stack. Otherwise, it pushes an error
message.

The lua_load function uses a user-supplied reader function to read the chunk.
The data argument is an opaque value passed to the reader function.

The chunkName argument gives a name to the chunk, which is used for error
messages and in debug information.

When mode is set to bt, lua_load detects whether the string is text or binary.

lua_load uses the stack internally, so the reader function must always leave
the stack unmodified when returning.

May return OK, SyntaxError, or MemoryError. May also return other values
corresponding to errors raised by the read function.

If the resulting function has upvalues, its first upvalue is set to the value of
the global environment stored at index LUA_RIDX_GLOBALS in the registry. When
loading main chunks, this upvalue will be the _ENV variable. Other upvalues are
initialized with nil.
"""
function lua_load(L::Ptr{LuaState}, reader::Ptr{Cvoid}, data::Ptr{Cvoid}, chunkName, mode::LuaLoadMode = bt)::LuaStatus
    return LuaStatus(ccall((:lua_load, liblua), Cint, (Ptr{LuaState}, Ptr{Cvoid}, Ptr{Cvoid}, Cstring, Cstring), L, reader, data, chunkName, String(Symbol(mode))))
end

"""
    lua_dump(L, writer, data, strip)

Dump the function on top of the stack as a binary chunk that, if loaded again,
results in a function equivalent to the one dumped. As it produces parts of the
chunk, lua_dump calls writer with the given data to write them. The function is
left on the stack.

If strip is true, the binary representation may not include all debug
information about the function, to save space.
    
Return OK or the error code produced by the last call to writer.    
"""
function lua_dump(L::Ptr{LuaState}, writer::Ptr{Cvoid}, data::Ptr{Cvoid}, strip::Bool)::LuaStatus
    return LuaStatus(ccall((:lua_dump, liblua), Cint, (Ptr{LuaState}, Ptr{Cvoid}, Ptr{Cvoid}, Cint), L, writer, data, strip))
end

# --- miscellaneous functions ---

"""
    lua_error(L)

Raises a Lua error, using the value on the top of the stack as the error object.
This function does a long jump, and therefore never returns (see luaL_error).
"""
function lua_error(L::Ptr{LuaState})::Nothing
    ccall((:lua_error, liblua), Cint, (Ptr{LuaState}, ), L)
end

# --- functions from lauxlib.h ---

function luaL_loadstring(L::Ptr{LuaState}, str)::LuaStatus
    return LuaStatus(ccall((:luaL_loadstring, liblua), Cint, (Ptr{LuaState}, Cstring), L, str))
end

function luaL_loadfilex(L::Ptr{LuaState}, filename, mode::LuaLoadMode = bt)::LuaStatus
    LuaStatus(ccall((:luaL_loadfilex, liblua), Cint, (Ptr{LuaState}, Cstring, Cstring), L, filename, String(Symbol(mode))))
end

function luaL_loadfile(L::Ptr{LuaState}, filename)::LuaStatus
    LuaStatus(ccall((:luaL_loadfilex, liblua), Cint, (Ptr{LuaState}, Cstring, Cstring), L, filename, C_NULL))
end
