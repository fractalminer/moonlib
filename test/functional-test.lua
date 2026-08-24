-----------------------------------------------------------------
-- Tests for the functional module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require'moon.unit.assertion'
local functional = require'moon.functional'

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local assert = assert

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT_TABLE_EQ = assertion.ASSERT_TABLE_EQ

local map = assert( functional.map )
local for_each = assert( functional.for_each )

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.map()
  local fn = function( n ) return n * n + 1 end
  do
    local lst = {}
    local mapped = map( fn, lst )
    local expected = {}
    ASSERT_TABLE_EQ( mapped, expected )
  end
  do
    local lst = { 2 }
    local mapped = map( fn, lst )
    local expected = { 5 }
    ASSERT_TABLE_EQ( mapped, expected )
  end
  do
    local lst = { 1, 2, 3 }
    local mapped = map( fn, lst )
    local expected = { 2, 5, 10 }
    ASSERT_TABLE_EQ( mapped, expected )
  end
end

function Test.for_each()
  local m = 0
  local fn = function( n ) m = m + n * n + 1 end
  do
    local lst = {}
    for_each( lst, fn )
    local expected = {}
    ASSERT_TABLE_EQ( lst, expected )
  end
  do
    local lst = { 2 }
    for_each( lst, fn )
    ASSERT_TABLE_EQ( lst, { 2 } )
    ASSERT_EQ( m, 5 )
  end
  do
    local lst = { 1, 2, 3 }
    for_each( lst, fn )
    ASSERT_TABLE_EQ( lst, { 1, 2, 3 } )
    ASSERT_EQ( m, 22 )
  end
end
