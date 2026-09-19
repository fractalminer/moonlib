-----------------------------------------------------------------
-- Tests for the xdelta module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require( 'moon.unit.assertion' )
local x = require( 'moon.xdelta' )

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
local encode = assert( x.encode )
local decode = assert( x.decode )

local ASSERT = assertion.ASSERT
local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT_LT = assertion.ASSERT_LT

-----------------------------------------------------------------
-- Data.
-----------------------------------------------------------------
local data = [[
#include <string>
#include <vector>

struct foo {
  int x;
  int y;
};

int square( int n ) {
  return n * n;
}

int main() {
  std::vector<int> v = { 1, 2, 3, 4 };
  return square( v[2] );
}
]]

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.round_trip()
  local modified = data .. [[

int cube( int n ) {
  return n * n * n;
}
]]

  local delta = encode( data, modified )

  ASSERT_EQ( type( delta ), 'string' )
  ASSERT_EQ( decode( data, delta ), modified )

  -- The delta should actually be substantially smaller than the
  -- input for this kind of modification.
  ASSERT( #delta < #modified )
end

function Test.identical()
  local delta = encode( data, data )

  ASSERT_EQ( type( delta ), 'string' )
  ASSERT_EQ( decode( data, delta ), data )
  ASSERT_LT( #delta, #data )
end

function Test.unrelated()
  local source = 'abcdefghijklmnopqrstuvwxyz'
  local input = '0123456789!@#$%^&*()'

  local delta = encode( source, input )

  ASSERT_EQ( decode( source, delta ), input )
end

function Test.empty()
  local delta = encode( '', '' )
  ASSERT_EQ( decode( '', delta ), '' )

  delta = encode( data, '' )
  ASSERT_EQ( decode( data, delta ), '' )

  delta = encode( '', data )
  ASSERT_EQ( decode( '', delta ), data )
end

function Test.binary()
  local source = '\0\1\2\3hello\0world\255\254\253'
  local input = '\0\1\2\3hello\0WORLD\255\254\253\0extra'

  local delta = encode( source, input )

  ASSERT_EQ( decode( source, delta ), input )
end
