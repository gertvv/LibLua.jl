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

const LUAI_MAXSTACK  = 1_000_000
const LUA_REGISTRYINDEX = -LUAI_MAXSTACK - 1000
const LUA_EXTRASPACE = sizeof(Ptr{Cvoid})

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
    # --- conversions.jl
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
    lua_register,
    # --- state.jl
    # state manipulation
    lua_newstate,
    lua_close,
    lua_newthread,
    lua_resetthread,
    lua_atpanic,
    lua_version,
    # lua_getextraspace,
    luaL_newstate,
    luaL_openlibs,
    # --- stack.jl
    # pseudo-indices
    lua_upvalueindex,
    # basic stack manipulation
    lua_absindex,
    lua_gettop,
    lua_settop,
    lua_pushvalue,
    lua_rotate,
    lua_copy,
    lua_checkstack,
    lua_xmove,
    # get functions (Lua -> stack)
    lua_getglobal,
    lua_gettable,
    lua_getfield,
    lua_geti,
    lua_rawget,
    lua_rawgeti,
    lua_rawgetp,
    lua_createtable,
    lua_newuserdatauv,
    lua_getmetatable,
    lua_getiuservalue,
    # set functions (stack -> Lua)
    lua_setglobal,
    lua_settable,
    lua_setfield,
    lua_seti,
    lua_rawset,
    lua_rawseti,
    lua_rawsetp,
    lua_setmetatable,
    lua_setiuservalue,
    # macros listed under "some useful macros"
    lua_pop,
    lua_newtable,
    lua_insert,
    lua_remove,
    lua_replace,
    # comparison and arithmetic functions
    # --- code.jl
    # 'load' and 'call' functions
    lua_callk,
    lua_call,
    lua_pcallk,
    lua_pcall,
    lua_load,
    lua_dump,
    # miscellaneous functions
    lua_error,
    # functions from lauxlib.h
    luaL_loadstring,
    luaL_loadfilex,
    luaL_loadfile,
    # coroutine functions
    # warning-related functions
    # garbage-collection functions and options
    # miscallaneous functions
    lua_next
end
