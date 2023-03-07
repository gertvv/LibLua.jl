# LibLua

Provides a light wrapper around Lua_jll that is close to a one-to-one mapping of
the Lua C API, with the following differences:

 - C macros are re-implemented as Julia functions.
 - Where the C API uses output arguments, the wrapper returns a tuple instead.
 - Where the C API returns integer status codes, enums are used instead.
 - TBD: Return errors nicely from `lua_p*` functions?
 - Functions that appear to be pointless in the context of Julia have been
   omitted (e.g. `lua_pushfstring`).

This is a work in progress, the API is not completely mapped, and test coverage
is poor.
