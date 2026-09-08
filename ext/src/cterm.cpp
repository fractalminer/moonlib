/****************************************************************
** Sample/Template Lua Module.
*****************************************************************/
#include "common.hpp"

#include <sys/ioctl.h>
#include <unistd.h>

namespace {

/****************************************************************
** Module Implementation.
*****************************************************************/
// Returns the size of the terminal:
//
//   local rows, cols = cterm.size()
//
int l_size( ::lua_State* const L ) {
  int const fd =
      ::isatty( STDOUT_FILENO ) ? STDOUT_FILENO : STDIN_FILENO;

  if( !::isatty( fd ) )
    return ::luaL_error( L, "no tty available" );

  ::winsize ws = {};

  if( ::ioctl( fd, TIOCGWINSZ, &ws ) == -1 )
    return ::luaL_error( L, "TIOCGWINSZ failed" );

  ::lua_pushinteger( L, ws.ws_row );
  ::lua_pushinteger( L, ws.ws_col );
  return 2;
}

/****************************************************************
** Module Definition.
*****************************************************************/
LUA_MODULE_FUNCTIONS( //
    size              //
);

} // namespace

LUA_MODULE( cterm );