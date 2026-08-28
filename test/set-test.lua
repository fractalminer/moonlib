-----------------------------------------------------------------
-- Tests for the set module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require( 'moon.unit.assertion' )
local set = require( 'moon.set' )
local list = require( 'moon.list' )

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local assert = assert
local ipairs = ipairs
local pairs = pairs
local table = table

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local listify = assert( list.listify )

local ASSERT = assertion.ASSERT
local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT_TABLE_EQ = assertion.ASSERT_TABLE_EQ

local insert = assert( table.insert )
local sort = assert( table.sort )

-----------------------------------------------------------------
-- Helpers.
-----------------------------------------------------------------
local function sorted( lst )
  local res = {}
  for _, elem in ipairs( lst ) do insert( res, elem ) end
  sort( res )
  return res
end

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.set()
  local s

  s = set()
  ASSERT_EQ( s:size(), 0 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( not s:contains( 'four' ) )
  ASSERT_TABLE_EQ( listify( pairs( s ) ), {} )
  s:add( 'four' )
  ASSERT_EQ( s:size(), 1 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( s:contains( 'four' ) )
  ASSERT_TABLE_EQ( listify( pairs( s ) ), { 'four' } )
  s:add( 'four' )
  ASSERT_EQ( s:size(), 1 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( s:contains( 'four' ) )
  ASSERT_TABLE_EQ( listify( pairs( s ) ), { 'four' } )
  s:del( 'two' )
  ASSERT_EQ( s:size(), 1 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( s:contains( 'four' ) )
  ASSERT_TABLE_EQ( listify( pairs( s ) ), { 'four' } )
  s:del( 'four' )
  ASSERT_EQ( s:size(), 0 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( not s:contains( 'four' ) )
  ASSERT_TABLE_EQ( listify( pairs( s ) ), {} )

  s = set{ 'one', 'two', 'three' }
  ASSERT_EQ( s:size(), 3 )
  ASSERT( s:contains( 'two' ) )
  ASSERT( not s:contains( 'xxx' ) )
  ASSERT_TABLE_EQ( sorted( listify( pairs( s ) ) ),
                   { 'one', 'three', 'two' } )
  s:add( 'two' )
  ASSERT_EQ( s:size(), 3 )
  ASSERT( s:contains( 'two' ) )
  ASSERT( not s:contains( 'xxx' ) )
  ASSERT_TABLE_EQ( sorted( listify( pairs( s ) ) ),
                   { 'one', 'three', 'two' } )
  s:add( 'xxx' )
  ASSERT_EQ( s:size(), 4 )
  ASSERT( s:contains( 'two' ) )
  ASSERT( s:contains( 'xxx' ) )
  ASSERT_TABLE_EQ( sorted( listify( pairs( s ) ) ),
                   { 'one', 'three', 'two', 'xxx' } )
  s:del( 'xxx' )
  ASSERT_EQ( s:size(), 3 )
  ASSERT( s:contains( 'two' ) )
  ASSERT( not s:contains( 'xxx' ) )
  ASSERT_TABLE_EQ( sorted( listify( pairs( s ) ) ),
                   { 'one', 'three', 'two' } )

  -- A few different ways to convert it to a list.
  local lst = {}
  for elem in pairs( s ) do insert( lst, elem ) end
  ASSERT_TABLE_EQ( sorted( lst ), { 'one', 'three', 'two' } )
  lst = listify( pairs( s ) )
  ASSERT_TABLE_EQ( sorted( lst ), { 'one', 'three', 'two' } )
  lst = s:list()
  ASSERT_TABLE_EQ( sorted( lst ), { 'one', 'three', 'two' } )
end
