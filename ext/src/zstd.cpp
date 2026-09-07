/****************************************************************
** Simple bindings for the zstd compression library.
*****************************************************************/
#include "common.hpp"

#include <zstd.h>

#include <cstdint>

namespace {

/****************************************************************
** Module Implementation.
*****************************************************************/
int l_compress( ::lua_State* const L ) {
  size_t src_size       = {};
  char const* const src = luaL_checklstring( L, 1, &src_size );
  int const level =
      static_cast<int>( luaL_optinteger( L, 2, 1 ) );

  size_t const bound = ::ZSTD_compressBound( src_size );

  ::luaL_Buffer buf = {};
  char* const dst   = luaL_buffinitsize( L, &buf, bound );

  size_t const dst_size =
      ::ZSTD_compress( dst, bound, src, src_size, level );

  if( ::ZSTD_isError( dst_size ) )
    return luaL_error( L, "zstd compression failed: %s",
                       ::ZSTD_getErrorName( dst_size ) );

  luaL_pushresultsize( &buf, dst_size );
  return 1;
}

int l_decompress( ::lua_State* const L ) {
  size_t src_size       = {};
  char const* const src = luaL_checklstring( L, 1, &src_size );

  size_t const size =
      ::ZSTD_getFrameContentSize( src, src_size );

  if( size == ZSTD_CONTENTSIZE_ERROR )
    return luaL_error( L, "invalid zstd frame" );

  if( size == ZSTD_CONTENTSIZE_UNKNOWN )
    return luaL_error(
        L, "zstd frame does not contain decompressed size" );

  if( size > SIZE_MAX )
    return luaL_error( L, "decompressed data is too large" );

  ::luaL_Buffer buf = {};
  char* const dst   = luaL_buffinitsize( L, &buf, size );

  size_t const dst_size =
      ::ZSTD_decompress( dst, size, src, src_size );

  if( ::ZSTD_isError( dst_size ) )
    return luaL_error( L, "zstd decompression failed: %s",
                       ::ZSTD_getErrorName( dst_size ) );

  if( dst_size != size )
    return luaL_error( L,
                       "zstd decompression size mismatch: "
                       "expected %zu, got %zu",
                       size, dst_size );

  luaL_pushresultsize( &buf, dst_size );
  return 1;
}

/****************************************************************
** Module Definition.
*****************************************************************/
LUA_MODULE_FUNCTIONS( //
    compress,         //
    decompress        //
);

} // namespace

LUA_MODULE( zstd );