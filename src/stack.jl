# --- Basic stack manipulation ---

"""
    lua_absindex(L, index)

Convert an acceptable index into an equivalent absolute index (that is, one
that does not depend on the stack size).
"""
function lua_absindex(L::Ptr{LuaState}, index)
    return ccall((:lua_absindex, liblua), Cint, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_gettop(L)

Return the index of the top element in the stack. Because indices start at 1,
this result is equal to the number of elements in the stack; in particular, 0
means an empty stack.
"""
function lua_gettop(L::Ptr{LuaState})
    return ccall((:lua_gettop, liblua), Cint, (Ptr{LuaState}, ), L)
end

"""
    lua_settop(L, index)

Accepts any index, or 0, and sets the stack top to this index. If the new top is
greater than the old one, then the new elements are filled with nil. If index is
0, then all stack elements are removed.

This function can run arbitrary code when removing an index marked as
to-be-closed from the stack.
"""
function lua_settop(L::Ptr{LuaState}, index)::Nothing
    ccall((:lua_settop, liblua), Cvoid, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_pushvalue(L, index)

Push a copy of the element at the given index onto the stack.
"""
function lua_pushvalue(L::Ptr{LuaState}, index)::Nothing
    ccall((:lua_pushvalue, liblua), Cvoid, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_rotate(L, index, n)

Rotate the stack elements between a valid index and the top of the stack. The
elements are rotated n positions in the direction of the top, for a positive n,
or -n positions in the direction of the bottom, for a negative n. The absolute
value of n must not be greater than the size of the slice being rotated. This
function cannot be called with a pseudo-index, because a pseudo-index is not an
actual stack position.
"""
function lua_rotate(L::Ptr{LuaState}, index, n)::Nothing
    ccall((:lua_rotate, liblua), Cvoid, (Ptr{LuaState}, Cint, Cint), L, index, n)
end

"""
    lua_copy(L, fromIndex, toIndex)

Copy the element at fromIndex into the valid index toIndex, replacing the value
at that position. Values at other positions are not affected.
"""
function lua_copy(L::Ptr{LuaState}, fromIndex, toIndex)::Nothing
    ccall((:lua_copy, liblua), Cvoid, (Ptr{LuaState}, Cint, Cint), L, fromIndex, toIndex)
end

"""
    lua_checkstack(L, n)

Ensure that the stack has space for at least n extra elements, that is, that you
can safely push up to n values into it. It returns false if it cannot fulfill
the request, either because it would cause the stack to be greater than a fixed
maximum size (typically at least several thousand elements) or because it cannot
allocate memory for the extra space. This function never shrinks the stack; if
the stack already has space for the extra elements, it is left unchanged.
"""
function lua_checkstack(L::Ptr{LuaState}, n)::Bool
    return Bool(ccall((:lua_checkstack, liblua), Cint, (Ptr{LuaState}, Cint), L, n))
end

"""
    lua_xmove(from, to, n)

Exchange values between different threads of the same state: pop n values from
the stack from, and push them onto the stack to.
"""
function lua_xmove(from::Ptr{LuaState}, to::Ptr{LuaState}, n)::Nothing
    ccall((:lua_xmove, liblua), Cvoid, (Ptr{LuaState}, Ptr{LuaState}, Cint), from, to, n)
end

# --- Get functions (Lua -> stack) ---

"""
    lua_getglobal(L, name)

Push onto the stack the value of the global name. Return the type of that value.
"""
function lua_getglobal(L::Ptr{LuaState}, name)::LuaType
    return LuaType(ccall((:lua_getglobal, liblua), Cint, (Ptr{LuaState}, Cstring), L, name))
end

"""
    lua_gettable(L, index)

Pushes onto the stack the value t[k], where t is the value at the given index
and k is the value on the top of the stack. Return the type of the pushed value.

This function pops the key from the stack, pushing the resulting value in its
place.

As in Lua, this function may trigger a metamethod for the "index" event.
"""
function lua_gettable(L::Ptr{LuaState}, index)::LuaType
    return LuaType(ccall((:lua_gettable, liblua), Cint, (Ptr{LuaState}, Cint), L, index))
end

"""
    lua_getfield(L, index, k)

Pushes onto the stack the value t[k], where t is the value at the given index.
Return the type of the pushed value.

As in Lua, this function may trigger a metamethod for the "index" event.
"""
function lua_getfield(L::Ptr{LuaState}, index, k)::LuaType
    return LuaType(ccall((:lua_getfield, liblua), Cint, (Ptr{LuaState}, Cint, Cstring), L, index, k))
end

"""
    lua_geti(L, index, i)

Pushes onto the stack the value t[i], where t is the value at the given index.
Return the type of the pushed value.

As in Lua, this function may trigger a metamethod for the "index" event.
"""
function lua_geti(L::Ptr{LuaState}, index, i)::LuaType
    return LuaType(ccall((:lua_geti, liblua), Cint, (Ptr{LuaState}, Cint, Cint), L, index, i))
end

"""
    lua_rawget(L, index)

Similar to lua_gettable, but does a raw access (i.e., without metamethods).
"""
function lua_rawget(L::Ptr{LuaState}, index)::LuaType
    return LuaType(ccall((:lua_rawget, liblua), Cint, (Ptr{LuaState}, Cint), L, index))
end

"""
    lua_rawgeti(L, index, i)

Similar to lua_geti, but does a raw access (i.e., without metamethods).
"""
function lua_rawgeti(L::Ptr{LuaState}, index, i)::LuaType
    return LuaType(ccall((:lua_rawgeti, liblua), Cint, (Ptr{LuaState}, Cint, Cint), L, index, i))
end

"""
    lua_rawgetp(L, index, p)

Push onto the stack the value t[k], where t is the table at the given index and
k is the pointer p represented as a light userdata. The access is raw; that is,
it does not call metamethods. Return the type of the pushed value.
"""
function lua_rawgetp(L::Ptr{LuaState}, index, p)::LuaType
    return LuaType(ccall((:lua_rawgetp, liblua), Cint, (Ptr{LuaState}, Cint, Ptr{Cvoid}), L, index, p))
end

"""
    lua_createtable(L, narr, nrec)

Create a new empty table and pushes it onto the stack. Parameter narr is a hint
for how many elements the table will have as a sequence; parameter nrec is a
hint for how many other elements the table will have. Lua may use these hints to
preallocate memory for the new table. This preallocation may help performance4
when you know in advance how many elements the table will have. Otherwise you
can use the function lua_newtable.
"""
function lua_createtable(L::Ptr{LuaState}, narr, nrec)::Nothing
    ccall((:lua_createtable, liblua), Cint, (Ptr{LuaState}, Cint, Cint), L, narr, nrec)
end

"""
    lua_newuserdatauv(L, size, nuvalue)

Create and push on the stack a new full userdata, with nuvalue associated Lua
values, called user values, plus an associated block of raw memory with size
bytes.

Return the address of the block of memory. Lua ensures that this address is
valid as long as the corresponding userdata is alive. Moreover, if the userdata
is marked for finalization, its address is valid at least until the call to its
finalizer.

The user values can be set and read with the functions lua_setiuservalue and4
lua_getiuservalue.
"""
function lua_newuserdatauv(L::Ptr{LuaState}, size, nuvalue)::Ptr{Cvoid}
    return ccall((:lua_newuserdatauv, liblua), Ptr{Cvoid}, (Ptr{LuaState}, Cint, Cint), L, size, nuvalue)
end

"""
    lua_getmetatable(L, index)

If the value at the given index has a metatable, push that metatable onto the
stack and return true. Otherwise, push nothing on the stack and return false.
"""
function lua_getmetatable(L::Ptr{LuaState}, index)::Bool
    return Bool(ccall((:lua_getmetatable, liblua), Cint, (Ptr{LuaState}, Cint), L, index))
end

"""
    lua_getiuservalue(L, index, i)

Push onto the stack the i-th user value associated with the full userdata at the
given index and return the type of the pushed value.

If the userdata does not have that value, push nil and return TNone.
"""
function lua_getiuservalue(L::Ptr{LuaState}, index, i)::LuaType
    return LuaType(ccall((:lua_getiuservalue, liblua), Cint, (Ptr{LuaState}, Cint, Cint), L, index, i))
end

# --- Set functions (stack -> Lua) ---

"""
    lua_setglobal(L, name)

Pop a value from the stack and set it as the new value of global name.
"""
function lua_setglobal(L::Ptr{LuaState}, name)::Nothing
    ccall((:lua_setglobal, liblua), Cvoid, (Ptr{LuaState}, Cstring), L, name)
end

"""
    lua_settable(L, index)

Set t[k] = v, where t is the value at the given index, v is the value on the
top of the stack, and k is the value just below the top.

Pop both the key and the value from the stack. As in Lua, this function may
trigger a metamethod for the "newindex" event.
"""
function lua_settable(L::Ptr{LuaState}, index)::Nothing
    ccall((:lua_settable, liblua), Cvoid, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_setfield(L, index, k)

Set t[k] = v, where t is the value at the given index and v is the value on the
top of the stack.

Pop the value from the stack. As in Lua, this function may trigger a metamethod
for the "newindex" event.
"""
function lua_setfield(L::Ptr{LuaState}, index, k)::Nothing
    ccall((:lua_setfield, liblua), Cvoid, (Ptr{LuaState}, Cint, Cstring), L, index, k)
end

"""
    lua_seti(L, index, i)

Set t[i] = v, where t is the value at the given index and v is the value on the
top of the stack.

Pop the value from the stack. As in Lua, this function may trigger a metamethod
for the "newindex" event.
"""
function lua_seti(L::Ptr{LuaState}, index, i)::Nothing
    ccall((:lua_seti, liblua), Cvoid, (Ptr{LuaState}, Cint, Cint), L, index, i)
end

"""
    lua_rawset(L, index)

Similar to lua_settable, but does a raw assignment (i.e., without metamethods).
"""
function lua_rawset(L::Ptr{LuaState}, index)::Nothing
    ccall((:lua_rawset, liblua), Cvoid, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_rawseti(L, index)

Similar to lua_seti, but does a raw assignment (i.e., without metamethods).
"""
function lua_rawseti(L::Ptr{LuaState}, index, i)::Nothing
    ccall((:lua_rawseti, liblua), Cvoid, (Ptr{LuaState}, Cint, Cint), L, index, i)
end

"""
Set t[p] = v, where t is the table at the given index, p is encoded as a light
userdata, and v is the value on the top of the stack.

Pop the value from the stack. The assignment is raw (i.e., without metamethods).
"""
function lua_rawsetp(L::Ptr{LuaState}, index, p)::Nothing
    ccall((:lua_rawsetp, liblua), Cvoid, (Ptr{LuaState}, Cint, Ptr{Cvoid}), L, index, p)
end

"""
    lua_setmetatable(L, index)

Pop a table or nil from the stack and set that value as the new metatable for
the value at the given index. Nil means no metatable.
"""
function lua_setmetatable(L::Ptr{LuaState}, index)::Nothing
    ccall((:lua_setmetatable, liblua), Cint, (Ptr{LuaState}, Cint), L, index)
end

"""
    lua_setiuservalue(L, index, i)
Pop a value from the stack and set it as the new i-th user value associated to
the full userdata at the given index. Return false if the userdata does not
have that value.
"""
function lua_setiuservalue(L::Ptr{LuaState}, index, i)::Bool
    return Bool(ccall((:lua_setiuservalue, liblua), Cint, (Ptr{LuaState}, Cint, Cint), L, index, i))
end

# --- Macros listed under "some useful macros" ---

"""
    lua_pop(L, n)

Pop n elements from the stack.
"""
function lua_pop(L::Ptr{LuaState}, n)::Nothing
    lua_settop(L, -n - 1)
end

"""
    lua_newtable(L)
Create a new empty table and push it onto the stack.
"""
function lua_newtable(L::Ptr{LuaState})::Nothing
    lua_createtable(L, 0, 0)
end

"""
    lua_insert(L, index)

Move the top element into the given valid index, shifting up the elements above
this index to open space. This function cannot be called with a pseudo-index,
because a pseudo-index is not an actual stack position.
"""
function lua_insert(L::Ptr{LuaState}, index)::Nothing
    lua_rotate(L, index, 1)
end

"""
    lua_remove(L, index)

Remove the element at the given valid index, shifting down the elements above
this index to fill the gap. This function cannot be called with a pseudo-index,
because a pseudo-index is not an actual stack position.
"""
function lua_remove(L::Ptr{LuaState}, index)::Nothing
    lua_rotate(L, index, -1)
    lua_pop(L, 1)
end

"""
    lua_replace(L, index)

Copy the top element into the given valid index without shifting any element
(therefore replacing the value at that given index), and then pop the top
element.
"""
function lua_replace(L::Ptr{LuaState}, index)::Nothing
    lua_copy(L, -1, index)
    lua_pop(L, 1)
end

#define lua_pushliteral(L, s)   lua_pushstring(L, "" s)

#define lua_pushglobaltable(L)  \
# ((void)lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS))