using LibLua
using Test

@testset "LibLua.jl" begin
    @testset "Define and run a Lua function" begin
        L = luaL_newstate()
        @test L != C_NULL
        luaL_openlibs(L)
        @test luaL_loadstring(L, "function square(n)\n    return n * n\nend") == LibLua.OK
        @test lua_pcall(L, 0, -1) == LibLua.OK
        @test lua_getglobal(L, "square") == LibLua.TFunction
        lua_pushinteger(L, 2)
        @test lua_pcall(L, 1, 1) == LibLua.OK
        @test lua_tointegerx(L, -1) == (4, true)
        lua_close(L)
    end
end
