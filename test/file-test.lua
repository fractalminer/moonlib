-----------------------------------------------------------------
-- Tests for the printer module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require( 'moon.unit.assertion' )
local file = require( 'moon.file' )

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local os = os
local io = io
local assert = assert

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local ASSERT = assertion.ASSERT
local ASSERT_EQ = assertion.ASSERT_EQ

local copy_file = assert( file.copy_file )
local exists = assert( file.exists )
local mkdir_p = assert( file.mkdir_p )
local is_path_absolute = assert( file.is_path_absolute )

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.copy_file()
  local input = '/tmp/abc123.txt'
  local output = '/tmp/123abc.txt'
  if exists( input ) then os.remove( input ) end
  if exists( output ) then os.remove( output ) end

  ASSERT( not exists( input ) )
  ASSERT( not exists( output ) )

  do
    local f<close> = assert( io.open( input, 'wb' ) )
    f:write( 'hello' )
  end

  ASSERT( exists( input ) )
  ASSERT( not exists( output ) )

  copy_file( input, output )

  ASSERT( exists( input ) )
  ASSERT( exists( output ) )

  do
    local f<close> = assert( io.open( output, 'rb' ) )
    local contents = f:read( '*a' )
    ASSERT_EQ( contents, 'hello' )
  end

  ASSERT( exists( input ) )
  ASSERT( exists( output ) )
end

function Test.mkdir_p()
  local d = '/tmp/aaa/bbb/ccc/ddd'

  local function rmdir( path )
    assert( path:sub( 1, 4 ) == '/tmp' )
    if exists( path ) then os.execute( 'rm -r ' .. path ) end
  end

  rmdir( '/tmp/aaa' )

  ASSERT( not exists( '/tmp/aaa' ) )
  ASSERT( not exists( d ) )

  mkdir_p( d )

  ASSERT( exists( '/tmp/aaa' ) )
  ASSERT( exists( d ) )

  mkdir_p( d )
  ASSERT( exists( d ) )

  rmdir( '/tmp/aaa/bbb/ccc' )
  ASSERT( not exists( d ) )
  ASSERT( not exists( '/tmp/aaa/bbb/ccc' ) )
  ASSERT( exists( '/tmp/aaa/bbb' ) )
  ASSERT( exists( '/tmp/aaa' ) )

  mkdir_p( d )
  ASSERT( exists( d ) )
end

function Test.is_path_absolute()
  ASSERT( not is_path_absolute( '' ) )
  ASSERT( not is_path_absolute( ' ' ) )
  ASSERT( not is_path_absolute( ' a ' ) )
  ASSERT( not is_path_absolute( ' /aaa ' ) )
  ASSERT( not is_path_absolute( ' /a/b/c' ) )
  ASSERT( is_path_absolute( '/a/b/c' ) )
  ASSERT( is_path_absolute( '/a/b/' ) )
  ASSERT( is_path_absolute( '/a/b/ ' ) )
  ASSERT( is_path_absolute( '/a/b' ) )
  ASSERT( is_path_absolute( '/a/' ) )
  ASSERT( is_path_absolute( '/aaa/' ) )
  ASSERT( is_path_absolute( '/aaa' ) )
  ASSERT( is_path_absolute( '/a' ) )
  ASSERT( is_path_absolute( '/' ) )
  ASSERT( is_path_absolute( '//' ) )
end
