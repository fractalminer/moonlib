/****************************************************************
** Simple bindings for the xdelta3 library.
*****************************************************************/
#include <xdelta3.h>

#include "common.hpp"

#include <cerrno>
#include <cstdint>

namespace {

/****************************************************************
** Module Implementation.
*****************************************************************/
int l_encode( ::lua_State* const L ) {
  size_t source_size = {};
  char const* const source =
      luaL_checklstring( L, 1, &source_size );

  size_t input_size = {};
  char const* const input =
      luaL_checklstring( L, 2, &input_size );

  /*
   * The delta cannot be larger than this buffer. In our use case
   * it should normally be tiny, but using input_size gives us a
   * simple upper bound for the first implementation.
   */
  size_t const capacity = input_size + 1024;

  ::luaL_Buffer buf  = {};
  char* const output = luaL_buffinitsize( L, &buf, capacity );

  usize_t output_size = capacity;

  int const res = ::xd3_encode_memory(
      reinterpret_cast<uint8_t const*>( input ), input_size,
      reinterpret_cast<uint8_t const*>( source ), source_size,
      reinterpret_cast<uint8_t*>( output ), &output_size,
      capacity, XD3_NOCOMPRESS );

  if( res != 0 )
    return luaL_error( L, "xdelta encode failed: %s",
                       ::xd3_strerror( res ) );

  luaL_pushresultsize( &buf, output_size );
  return 1;
}

int l_decode( ::lua_State* const L ) {
  size_t source_size = {};
  char const* const source =
      luaL_checklstring( L, 1, &source_size );

  size_t delta_size = {};
  char const* const delta =
      luaL_checklstring( L, 2, &delta_size );

  // Assume that the reconstructed file will normally be fairly
  // close in size to the source. NOTE: this must be larger than
  // zero for any source_size otherwise the retry loop below will
  // never terminate.
  constexpr size_t extra_capacity = 64 * 1024;

  if( source_size > SIZE_MAX - extra_capacity )
    return luaL_error( L, "xdelta source is too large" );

  size_t capacity = source_size + extra_capacity;

  for( ;; ) {
    ::luaL_Buffer buf  = {};
    char* const output = luaL_buffinitsize( L, &buf, capacity );

    usize_t output_size = capacity;

    int const res = ::xd3_decode_memory(
        reinterpret_cast<uint8_t const*>( delta ), delta_size,
        reinterpret_cast<uint8_t const*>( source ), source_size,
        reinterpret_cast<uint8_t*>( output ), &output_size,
        capacity, 0 );

    if( res == 0 ) {
      luaL_pushresultsize( &buf, output_size );
      return 1;
    }

    // Discard the unfinished Lua buffer before retrying.
    luaL_pushresultsize( &buf, 0 );
    lua_pop( L, 1 );

    if( res != ENOSPC )
      return luaL_error( L, "xdelta decode failed: %s",
                         ::xd3_strerror( res ) );

    if( capacity > SIZE_MAX / 2 )
      return luaL_error( L,
                         "xdelta decoded output is too large" );

    capacity *= 2;
  }
}

/****************************************************************
** Module Definition.
*****************************************************************/
LUA_MODULE_FUNCTIONS( //
    encode,           //
    decode            //
);

} // namespace

LUA_MODULE( xdelta );