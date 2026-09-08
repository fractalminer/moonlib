-----------------------------------------------------------------
-- Tests for the zstd module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require( 'moon.unit.assertion' )
local z = require( 'moon.zstd' )

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local assert = assert
local type = type

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local compress = assert( z.compress )
local decompress = assert( z.decompress )

local ASSERT = assertion.ASSERT
local ASSERT_EQ = assertion.ASSERT_EQ

-----------------------------------------------------------------
-- Data.
-----------------------------------------------------------------
local data = [[
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
  hello hello hello hello hello hello hello hello hello hello
]]

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.round_trip_l1()
  ASSERT( not not z )
  ASSERT_EQ( #data, 992 )

  local c = compress( data )
  ASSERT( not not c )
  ASSERT_EQ( type( c ), 'string' )
  ASSERT_EQ( #c, 34 )

  local d = decompress( c )
  ASSERT( not not d )
  ASSERT_EQ( type( d ), 'string' )
  ASSERT_EQ( #d, 992 )
  ASSERT_EQ( d, data )
end

function Test.round_trip_l9()
  ASSERT( not not z )
  ASSERT_EQ( #data, 992 )

  local c = compress( data, 9 )
  ASSERT( not not c )
  ASSERT_EQ( type( c ), 'string' )
  ASSERT_EQ( #c, 28 )

  local d = decompress( c )
  ASSERT( not not d )
  ASSERT_EQ( type( d ), 'string' )
  ASSERT_EQ( #d, 992 )
  ASSERT_EQ( d, data )
end
