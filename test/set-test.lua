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
local table = table
local tostring = tostring
local pairs = pairs

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local listify = assert( list.listify )

local ASSERT = assertion.ASSERT
local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT_TABLE_EQ = assertion.ASSERT_TABLE_EQ
local ASSERT_THROWS = assertion.ASSERT_THROWS

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
  ASSERT( s:empty() )
  ASSERT_EQ( s:size(), 0 )
  ASSERT_EQ( #s, 0 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( not s:contains( 'four' ) )
  ASSERT_TABLE_EQ( s:sorted(), {} )
  s:add( 'four' )
  ASSERT_EQ( s:size(), 1 )
  ASSERT_EQ( #s, 1 )
  ASSERT( not s:empty() )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( s:contains( 'four' ) )
  ASSERT_TABLE_EQ( s:sorted(), { 'four' } )
  s:add( 'four' )
  ASSERT_EQ( s:size(), 1 )
  ASSERT( not s:empty() )
  ASSERT_EQ( #s, 1 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( s:contains( 'four' ) )
  ASSERT_TABLE_EQ( s:sorted(), { 'four' } )
  s:del( 'two' )
  ASSERT_EQ( s:size(), 1 )
  ASSERT( not s:empty() )
  ASSERT_EQ( #s, 1 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( s:contains( 'four' ) )
  ASSERT_TABLE_EQ( s:sorted(), { 'four' } )
  s:del( 'four' )
  ASSERT_EQ( s:size(), 0 )
  ASSERT( s:empty() )
  ASSERT_EQ( #s, 0 )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( not s:contains( 'four' ) )
  ASSERT_TABLE_EQ( s:sorted(), {} )

  s = set{ 'one', 'two', 'three' }
  ASSERT_EQ( s:size(), 3 )
  ASSERT_EQ( #s, 3 )
  ASSERT( not s:empty() )
  ASSERT( s:contains( 'two' ) )
  ASSERT( not s:contains( 'xxx' ) )
  ASSERT_TABLE_EQ( s:sorted(), { 'one', 'three', 'two' } )
  s:add( 'two' )
  ASSERT_EQ( s:size(), 3 )
  ASSERT( not s:empty() )
  ASSERT_EQ( #s, 3 )
  ASSERT( s:contains( 'two' ) )
  ASSERT( not s:contains( 'xxx' ) )
  ASSERT_TABLE_EQ( s:sorted(), { 'one', 'three', 'two' } )
  s:add( 'xxx' )
  ASSERT_EQ( s:size(), 4 )
  ASSERT( not s:empty() )
  ASSERT_EQ( #s, 4 )
  ASSERT( s:contains( 'two' ) )
  ASSERT( s:contains( 'xxx' ) )
  ASSERT_TABLE_EQ( s:sorted(), { 'one', 'three', 'two', 'xxx' } )
  s:del( 'xxx' )
  ASSERT_EQ( s:size(), 3 )
  ASSERT( not s:empty() )
  ASSERT_EQ( #s, 3 )
  ASSERT( s:contains( 'two' ) )
  ASSERT( not s:contains( 'xxx' ) )
  ASSERT_TABLE_EQ( s:sorted(), { 'one', 'three', 'two' } )

  -- A few different ways to convert it to a list.
  local lst = {}
  for elem in s do insert( lst, elem ) end
  ASSERT_TABLE_EQ( sorted( lst ), { 'one', 'three', 'two' } )
  lst = listify( s )
  ASSERT_TABLE_EQ( sorted( lst ), { 'one', 'three', 'two' } )
  lst = s:sorted()
  ASSERT_TABLE_EQ( sorted( lst ), { 'one', 'three', 'two' } )

  s:clear()
  ASSERT_EQ( s:size(), 0 )
  ASSERT_EQ( #s, 0 )
  ASSERT( s:empty() )
  ASSERT( not s:contains( 'two' ) )
  ASSERT( not s:contains( 'xxx' ) )

  local s1, s2, s3
  s1 = set{ 'one', 'two', 'three', 'four' }
  s2 = set{ 'two', 'four', 'abc', 'def' }
  s3 = s1:clone()
  ASSERT_TABLE_EQ( s1:sorted(), { 'four', 'one', 'three', 'two' } )
  ASSERT_TABLE_EQ( s2:sorted(), { 'abc', 'def', 'four', 'two' } )
  ASSERT_TABLE_EQ( s3:sorted(), { 'four', 'one', 'three', 'two' } )
  s3 = s1:diff( s2 )
  ASSERT_TABLE_EQ( s1:sorted(), { 'four', 'one', 'three', 'two' } )
  ASSERT_TABLE_EQ( s2:sorted(), { 'abc', 'def', 'four', 'two' } )
  ASSERT_TABLE_EQ( s3:sorted(), { 'one', 'three' } )
  s1:subtract( s3 )
  ASSERT_TABLE_EQ( s1:sorted(), { 'four', 'two' } )
  ASSERT_TABLE_EQ( s2:sorted(), { 'abc', 'def', 'four', 'two' } )
  ASSERT_TABLE_EQ( s3:sorted(), { 'one', 'three' } )
  s2 = s2 - s3
  ASSERT_TABLE_EQ( s1:sorted(), { 'four', 'two' } )
  ASSERT_TABLE_EQ( s2:sorted(), { 'abc', 'def', 'four', 'two' } )
  ASSERT_TABLE_EQ( s3:sorted(), { 'one', 'three' } )
  s2 = s2 - set()
  ASSERT_TABLE_EQ( s1:sorted(), { 'four', 'two' } )
  ASSERT_TABLE_EQ( s2:sorted(), { 'abc', 'def', 'four', 'two' } )
  ASSERT_TABLE_EQ( s3:sorted(), { 'one', 'three' } )
  s2 = s2 - s1
  ASSERT_TABLE_EQ( s1:sorted(), { 'four', 'two' } )
  ASSERT_TABLE_EQ( s2:sorted(), { 'abc', 'def' } )
  ASSERT_TABLE_EQ( s3:sorted(), { 'one', 'three' } )
  s2 = s2 - s2
  ASSERT_TABLE_EQ( s1:sorted(), { 'four', 'two' } )
  ASSERT_TABLE_EQ( s2:sorted(), {} )
  ASSERT_TABLE_EQ( s3:sorted(), { 'one', 'three' } )
  s1:subtract( s1 )
  ASSERT_TABLE_EQ( s1:sorted(), {} )
  ASSERT_TABLE_EQ( s2:sorted(), {} )
  ASSERT_TABLE_EQ( s3:sorted(), { 'one', 'three' } )
  s3 = s3:diff( s1 )
  ASSERT_TABLE_EQ( s1:sorted(), {} )
  ASSERT_TABLE_EQ( s2:sorted(), {} )
  ASSERT_TABLE_EQ( s3:sorted(), { 'one', 'three' } )
  s3 = s3:diff( s3 )
  ASSERT_TABLE_EQ( s1:sorted(), {} )
  ASSERT_TABLE_EQ( s2:sorted(), {} )
  ASSERT_TABLE_EQ( s3:sorted(), {} )

  s = set{}
  ASSERT_EQ( tostring( s ), '{}' )
  s = set{ 'one' }
  ASSERT_EQ( tostring( s ), '{one}' )
  s = set{ 'one', 'two' }
  ASSERT_EQ( tostring( s ), '{one,two}' )
  s = set{ 'one', 'two', 'three', 'four' }
  ASSERT_EQ( s:tostring(), '{four,one,three,two}' )

  ASSERT_THROWS( pairs, s )
end
