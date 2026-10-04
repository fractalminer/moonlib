-----------------------------------------------------------------
-- Tests for the freeze module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require'moon.unit.assertion'
local freeze = require'moon.freeze'

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local assert = assert
local ipairs = ipairs
local pairs = pairs
local table = table
local setmetatable = setmetatable
local getmetatable = getmetatable

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local insert = table.insert

local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT_THROWS_SUBSTR = assertion.ASSERT_THROWS_SUBSTR

local harden = assert( freeze.harden )

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.harden()
  local o = harden{
    a=42,
    bb='hello',
    c={
      d=3.4,
      e={ [1]='first', [2]='second', [3]='third' },
      f='last',
    },
  }

  local no_meta = setmetatable( {}, { __metatable=false } )

  local ERR_MOD = 'attempt to modify a read-only table'
  local ERR_KEY = 'attempt to read non-existent key'
  local ERR_META = 'metatable is hidden'

  ASSERT_EQ( o.a, 42 )
  ASSERT_EQ( o.bb, 'hello' )
  ASSERT_EQ( o.c.d, 3.4 )
  ASSERT_EQ( o.c.e[2], 'second' )
  ASSERT_EQ( #o.c.e, 3 )

  local ATS = ASSERT_THROWS_SUBSTR

  ATS( ERR_MOD, function() o.a = 1 end )
  ATS( ERR_MOD, function() o.bb = 'hello' end )
  ATS( ERR_MOD, function() o.f = {} end )
  ATS( ERR_MOD, function() o.c.e[2] = 0 end )
  ATS( ERR_MOD, function() o.c.e[4] = 0 end )
  ATS( ERR_MOD, function() o.c.e[5] = 0 end )
  ATS( ERR_META, function() harden( no_meta ) end )
  ATS( ERR_KEY, function() return o.f end )
  ATS( ERR_KEY, function() return o[5.5] end )

  ASSERT_EQ( getmetatable( o ), false )

  local test_ipairs = {}
  for _, elem in ipairs( o.c.e ) do insert( test_ipairs, elem ) end
  ASSERT_EQ( #test_ipairs, 3 )
  ASSERT_EQ( test_ipairs[1], 'first' )
  ASSERT_EQ( test_ipairs[2], 'second' )
  ASSERT_EQ( test_ipairs[3], 'third' )
  ASSERT_EQ( test_ipairs[4], nil )
  ASSERT_EQ( test_ipairs[5], nil )

  local test_pairs = {}
  for k, v in pairs( o.c ) do insert( test_pairs, { k=k, v=v } ) end
  table.sort( test_pairs, function( l, r )
    return assert( l.k ) < assert( r.k )
  end )
  ASSERT_EQ( #test_pairs, 3 )
  ASSERT_EQ( test_pairs[1].k, 'd' )
  ASSERT_EQ( test_pairs[2].k, 'e' )
  ASSERT_EQ( test_pairs[3].k, 'f' )
end
