module LibLua

using Lua_jll

mutable struct LuaState
end

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

include("conversions.jl")

include("state.jl")

include("stack.jl")

include("code.jl")

# --- Comparison and arithmetic functions ---

#define LUA_OPADD       0       /* ORDER TM, ORDER OP */
#define LUA_OPSUB       1
#define LUA_OPMUL       2
#define LUA_OPMOD       3
#define LUA_OPPOW       4
#define LUA_OPDIV       5
#define LUA_OPIDIV      6
#define LUA_OPBAND      7
#define LUA_OPBOR       8
#define LUA_OPBXOR      9
#define LUA_OPSHL       10
#define LUA_OPSHR       11
#define LUA_OPUNM       12
#define LUA_OPBNOT      13

# LUA_API void  (lua_arith) (lua_State *L, int op);

#define LUA_OPEQ        0
#define LUA_OPLT        1
#define LUA_OPLE        2

# LUA_API int   (lua_rawequal) (lua_State *L, int idx1, int idx2);
# LUA_API int   (lua_compare) (lua_State *L, int idx1, int idx2, int op);

# --- Macros listed under "some useful macros" ---

#define lua_isfunction(L,n)     (lua_type(L, (n)) == LUA_TFUNCTION)
#define lua_istable(L,n)        (lua_type(L, (n)) == LUA_TTABLE)
#define lua_islightuserdata(L,n)        (lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
#define lua_isnil(L,n)          (lua_type(L, (n)) == LUA_TNIL)
#define lua_isboolean(L,n)      (lua_type(L, (n)) == LUA_TBOOLEAN)
#define lua_isthread(L,n)       (lua_type(L, (n)) == LUA_TTHREAD)
#define lua_isnone(L,n)         (lua_type(L, (n)) == LUA_TNONE)
#define lua_isnoneornil(L, n)   (lua_type(L, (n)) <= 0)

# --- Coroutine functions ---


# --- Warning-related functions ---


# --- Garbage-collection function and options


# --- Miscellaneous functions ---

function lua_next(L::Ptr{LuaState}, index)
    return ccall((:lua_next, liblua), Cint, (Ptr{LuaState}, Cint), L, index)
end

export
    # types
    LuaState,
    LuaStatus,
    LuaType,
    LuaLoadMode,
    # state manipulation
    lua_newstate,
    lua_close,
    lua_newthread,
    lua_resetthread,
    lua_atpanic,
    lua_version,
    luaL_newstate,
    luaL_openlibs,
    # stack manipulation
    lau_absindex,
    # access functions (stack -> C)
    lua_type,
    lua_tonumberx,
    lua_tonumber,
    lua_tointegerx,
    lua_tointeger,
    lua_toboolean,
    lua_tolstring,
    lua_tostring,
    lua_tocfunction,
    lua_touserdata,
    lua_tothread,
    lua_topointer,
    # comparison and arithmetic functions
    # push functions (C -> stack)
    lua_pushnil,
    lua_pushnumber,
    lua_pushinteger,
    lua_pushlstring,
    lua_pushstring,
    lua_pushcclosure,
    lua_pushcfunction,
    lua_pushboolean,
    lua_pushlightuserdata,
    lua_pushthread,
    # get functions (Lua -> stack)
    lua_getglobal,
    lua_getfield,
    lua_settop,
    lua_rotate,
    # macros listed under "some useful macros"
    lua_pop,
    lua_remove,
    # set functions (stack -> Lua)
    # 'load' and 'call' functions
    luaL_loadstring,
    luaL_loadfilex,
    luaL_loadfile,
    lua_callk,
    lua_call,
    lua_pcallk,
    lua_pcall,
    # coroutine functions
    # warning-related functions
    # garbage-collection functions and options
    # miscallaneous functions
    lua_next
end
