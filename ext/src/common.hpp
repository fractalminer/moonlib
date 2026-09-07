/****************************************************************
** Common stuff for lua modules.
*****************************************************************/
#include <lauxlib.h>
#include <lua.h>

#include <boost/preprocessor/cat.hpp>
#include <boost/preprocessor/seq/for_each.hpp>
#include <boost/preprocessor/stringize.hpp>
#include <boost/preprocessor/variadic/to_seq.hpp>

#define GENERATE_LUA_REG_ROW( r, data, elem ) \
  { BOOST_PP_STRINGIZE( elem ), BOOST_PP_CAT( l_, elem ) },

#define MODULE_FUNCTIONS_SEQ( seq )                            \
  ::luaL_Reg const functions[] = {                             \
    BOOST_PP_SEQ_FOR_EACH( GENERATE_LUA_REG_ROW, BOOST_PP_NIL, \
                           seq ){ NULL, NULL } };

#define LUA_MODULE_FUNCTIONS( ... ) \
  MODULE_FUNCTIONS_SEQ( BOOST_PP_VARIADIC_TO_SEQ( __VA_ARGS__ ) )

#define LUA_MODULE( name )                                     \
  extern "C" int luaopen_moon_##name( ::lua_State* const L ) { \
    luaL_newlib( L, functions );                               \
    return 1;                                                  \
  }
