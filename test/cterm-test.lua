-----------------------------------------------------------------
-- Tests for the cterm module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require( 'moon.unit.assertion' )
local cterm = require( 'moon.cterm' )

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local os = os
local type = type
local tonumber = tonumber

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local ASSERT = assertion.ASSERT
local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT_GE = assertion.ASSERT_GE

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.size()
  local res = { cterm.size() }
  ASSERT( not not res )
  ASSERT_EQ( #res, 2 )
  ASSERT_EQ( type( res[1] ), 'number' )
  ASSERT_EQ( type( res[2] ), 'number' )
  local rows, cols = res[1], res[2]
  ASSERT_GE( rows, 0 )
  ASSERT_EQ( cols, tonumber( os.getenv( 'COLUMNS' ) ) )
end
