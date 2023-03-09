using LibLua
using Test

function square(L::Ptr{LibLua.LuaState})::Cint
    x = lua_tonumber(L, 1)
    lua_pushnumber(L, x^2)
    return 1
end

@testset "LibLua.jl" begin
    @testset "Push and access basic stack values" begin
        L = luaL_newstate()
        @test L != C_NULL

        lua_pushnil(L)
        @test lua_type(L, -1) == LibLua.TNil

        lua_pushinteger(L, 3)
        @test lua_type(L, -1) == LibLua.TNumber
        @test lua_tointegerx(L, -1) == (3, true)
        @test lua_tointeger(L, -1) == 3
        @test lua_tonumberx(L, -1) == (3.0, true)
        @test lua_tonumber(L, -1) == 3.0
        @test lua_toboolean(L, -1) == true

        lua_pushnumber(L, 7.1)
        @test lua_type(L, -1) == LibLua.TNumber
        @test lua_tonumberx(L, -1) == (7.1, true)
        @test lua_tonumber(L, -1) == 7.1
        @test lua_tointegerx(L, -1) == (0, false)
        @test lua_toboolean(L, -1) == true

        lua_pushboolean(L, true)
        @test lua_type(L, -1) == LibLua.TBoolean
        @test lua_toboolean(L, -1) == true

        @test unsafe_string(lua_pushlstring(L, "Hello, world!", 5)) == "Hello"
        @test lua_type(L, -1) == LibLua.TString
        @test lua_tolstring(L, -1) == ("Hello", 5)
        @test lua_tostring(L, -1) == "Hello"
        @test unsafe_string(lua_pushstring(L, "Hello, world!")) == "Hello, world!"
        @test lua_type(L, -1) == LibLua.TString
        @test lua_tostring(L, -1) == "Hello, world!"

        ud = Ref{Int64}(42)
        lua_pushlightuserdata(L, ud)
        @test lua_type(L, -1) == LibLua.TLightUserData
        @test lua_touserdata(L, -1) == pointer_from_objref(ud)
        @test lua_topointer(L, -1) == pointer_from_objref(ud)

        fn = @cfunction(square, Cint, (Ptr{LuaState},))
        lua_pushcfunction(L, fn)
        @test lua_type(L, -1) == LibLua.TFunction
        @test lua_tocfunction(L, -1) == fn
        @test lua_topointer(L, -1) == fn
        lua_pushinteger(L, 10)
        lua_pushcclosure(L, fn, 1)
        @test lua_type(L, -1) == LibLua.TFunction
        @test lua_tocfunction(L, -1) == fn
        @test lua_topointer(L, -1) != C_NULL

        @test lua_pushthread(L) == true
        @test lua_type(L, -1) == LibLua.TThread
        @test lua_tothread(L, -1) != C_NULL
    end

    @testset "Getting globals" begin
        L = luaL_newstate()
        @test L != C_NULL
        @test luaL_loadstring(L, "n = 3\nx = 5.2\ns = 'Test 123'\nt = {}") == LibLua.OK
        @test lua_pcall(L, 0, -1) == LibLua.OK
        @test lua_getglobal(L, "n") == LibLua.TNumber
        @test lua_tointeger(L, -1) == 3
        @test lua_getglobal(L, "x") == LibLua.TNumber
        @test lua_tonumber(L, -1) == 5.2
        @test lua_getglobal(L, "s") == LibLua.TString
        @test lua_tostring(L, -1) == "Test 123"
        @test lua_getglobal(L, "t") == LibLua.TTable
    end

    @testset "Define and run a Lua function" begin
        L = luaL_newstate()
        @test L != C_NULL
        @test luaL_loadstring(L, "function square(n)\n    return n * n\nend") == LibLua.OK
        @test lua_pcall(L, 0, -1) == LibLua.OK
        @test lua_getglobal(L, "square") == LibLua.TFunction
        lua_pushinteger(L, 2)
        @test lua_pcall(L, 1, 1) == LibLua.OK
        @test lua_tointegerx(L, -1) == (4, true)
        lua_close(L)
    end

    @testset "Define and run a C function" begin
        L = luaL_newstate()
        @test L != C_NULL
        fn = @cfunction(square, Cint, (Ptr{LuaState},))
        lua_pushcfunction(L, fn)
        lua_pushinteger(L, 2)
        @test lua_pcall(L, 1, 1) == LibLua.OK
        @test lua_tointegerx(L, -1) == (4, true)
        lua_close(L)
    end

end