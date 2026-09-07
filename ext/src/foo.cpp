/****************************************************************
** Sample/Template Lua Module.
*****************************************************************/
#include "common.hpp"

#include <iostream>
#include <sstream>

namespace {

/****************************************************************
** Module Implementation.
*****************************************************************/
int l_foo( ::lua_State* const L ) {
  int const arg = luaL_checkinteger( L, 1 );
  std::ostringstream oss;
  oss << "the arg is [" << arg << "].";
  lua_pushstring( L, oss.str().c_str() );
  return 1;
}

int l_bar( ::lua_State* const ) {
  std::cout << "hello\n";
  std::cout << "hello\n";
  std::cout << "hello\n";
  return 0;
}

/****************************************************************
** Module Definition.
*****************************************************************/
LUA_MODULE_FUNCTIONS( //
    foo,              //
    bar               //
);

} // namespace

LUA_MODULE( foo );