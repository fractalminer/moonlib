-----------------------------------------------------------------
-- Tests for the printer module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require'moon.unit.assertion'
local list = require'moon.list'

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
-- None.

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT_TABLE_EQ = assertion.ASSERT_TABLE_EQ

local split = list.split
local tsplit = list.tsplit
local tsplit_trim = list.tsplit_trim
local split_trim = list.split_trim

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.listify()
  local input, sep, expected

  -- input = ''
  -- sep = ','
  -- expected = { '' }
  -- ASSERT_TABLE_EQ( split( input, sep ), expected )
  -- TODO
end
