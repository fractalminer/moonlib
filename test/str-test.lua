-----------------------------------------------------------------
-- Tests for the str module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require'moon.unit.assertion'
local str = require'moon.str'

-----------------------------------------------------------------
-- Freeze global access.
-----------------------------------------------------------------
-- Declare all globals used.
local assert = assert
local string = string

-- No reading or writing of globals from here on.
local _ENV = nil

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT_NEQ = assertion.ASSERT_NEQ
local ASSERT_TABLE_EQ = assertion.ASSERT_TABLE_EQ

local split = assert( str.split )
local split_trim = assert( str.split_trim )
local tsplit = assert( str.tsplit )
local tsplit_trim = assert( str.tsplit_trim )

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.split()
  local input, sep, expected

  input = ''
  sep = ','
  expected = { '' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  input = ''
  sep = ','
  expected = { '' }
  ASSERT_TABLE_EQ( split_trim( input, sep ), expected )

  input = ''
  sep = ','
  expected = {}
  ASSERT_TABLE_EQ(
      split_trim( input, sep, { remove_empty=true } ), expected )

  input = 'a'
  sep = '|'
  expected = { 'a' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  input = 'abc|'
  sep = '|'
  expected = { 'abc', '' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  input = '|abc|'
  sep = '|'
  expected = { '', 'abc', '' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  input = 'aaa-bbb-ccc'
  sep = '-'
  expected = { 'aaa', 'bbb', 'ccc' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  input = 'aaa,  bbb, ccc '
  sep = ','
  expected = { 'aaa', '  bbb', ' ccc ' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  input = 'aaa,  bbb, ccc '
  sep = ','
  expected = { 'aaa', 'bbb', 'ccc' }
  ASSERT_TABLE_EQ( split_trim( input, sep ), expected )

  input = 'aaa--bbb-ccc'
  sep = '-'
  expected = { 'aaa', '', 'bbb', 'ccc' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  input = 'one_%_two_%_three'
  sep = '_'
  expected = { 'one', '%', 'two', '%', 'three' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  input = 'one_%_two_%_three'
  sep = '_%'
  expected = { 'one', '_two', '_three' }
  ASSERT_TABLE_EQ( split( input, sep, true ), expected )

  input = 'one_%_two_%_three'
  sep = '_%_'
  expected = { 'one', 'two', 'three' }
  ASSERT_TABLE_EQ( split( input, sep, true ), expected )

  input = 'one_%_two_%_three'
  sep = '%'
  expected = { 'one_', '_two_', '_three' }
  ASSERT_TABLE_EQ( split( input, sep, true ), expected )

  input = 'one_%_two_%_three_%_'
  sep = '_'
  expected = { 'one', '%', 'two', '%', 'three', '%', '' }
  ASSERT_TABLE_EQ( split( input, sep, true ), expected )

  input = 'one_%_two_%_three_%_'
  sep = '_%'
  expected = { 'one', '_two', '_three', '_' }
  ASSERT_TABLE_EQ( split( input, sep, true ), expected )

  input = 'one_%_two_%_three_%_'
  sep = '_%_'
  expected = { 'one', 'two', 'three', '' }
  ASSERT_TABLE_EQ( split( input, sep, true ), expected )

  input = 'one_%_two_%_three_%_'
  sep = '%'
  expected = { 'one_', '_two_', '_three_', '_' }
  ASSERT_TABLE_EQ( split( input, sep, true ), expected )

  input = [[
    one    two
      three
  ]]
  sep = '%s+'
  expected = { '', 'one', 'two', 'three', '' }
  ASSERT_TABLE_EQ( split( input, sep ), expected )

  do
    input = 'xxx=yyy|aaa=bbb|ccc=ddd\thello=2/1/0'
    local part1, part2 = tsplit( input, '\t' )
    local xxx_yyy, aaa_bbb, ccc_ddd = tsplit( part1, '|' )
    local hello, nums = tsplit( part2, '=' )
    local xxx, yyy = tsplit( xxx_yyy, '=' )
    local aaa, bbb = tsplit( aaa_bbb, '=' )
    local ccc, ddd = tsplit( ccc_ddd, '=' )
    ASSERT_EQ( hello, 'hello' )
    ASSERT_EQ( nums, '2/1/0' )
    ASSERT_EQ( xxx, 'xxx' )
    ASSERT_EQ( yyy, 'yyy' )
    ASSERT_EQ( aaa, 'aaa' )
    ASSERT_EQ( bbb, 'bbb' )
    ASSERT_EQ( ccc, 'ccc' )
    ASSERT_EQ( ddd, 'ddd' )
  end

  do
    input = 'xxx=yyy'
    local k, v = tsplit( input, '=' )
    ASSERT_EQ( k, 'xxx' )
    ASSERT_EQ( v, 'yyy' )
  end

  do
    input = 'xxx'
    local k, v = tsplit( input, '=' )
    ASSERT_EQ( k, 'xxx' )
    ASSERT_EQ( v, nil )
  end

  do
    input = 'aaa, bbb, ccc   ; comment'
    local config = split_trim( input, ';' )[1]
    local aaa, bbb, ccc = tsplit_trim( config, ',' )
    ASSERT_EQ( aaa, 'aaa' )
    ASSERT_EQ( bbb, 'bbb' )
    ASSERT_EQ( ccc, 'ccc' )
  end

  do
    input = 'aaa, bbb, ccc'
    local config = split_trim( input, ';' )[1]
    local aaa, bbb, ccc = tsplit_trim( config, ',' )
    ASSERT_EQ( aaa, 'aaa' )
    ASSERT_EQ( bbb, 'bbb' )
    ASSERT_EQ( ccc, 'ccc' )
  end

  do
    input = 'aaa, bbb, ccc'
    local config = split_trim( input, ';' )[1]
    local aaa, bbb, ccc = tsplit_trim( config, ',',
                                       { remove_empty=true } )
    ASSERT_EQ( aaa, 'aaa' )
    ASSERT_EQ( bbb, 'bbb' )
    ASSERT_EQ( ccc, 'ccc' )
  end

  do
    input = ' ; aaa, bbb, ccc'
    local config = split_trim( input, ';' )[1]
    local items =
        split_trim( config, ',', { remove_empty=true } )
    ASSERT_EQ( #items, 0 )
  end

  do
    input = ' xxx ; aaa, bbb, ccc'
    local config = split_trim( input, ';' )[1]
    local items =
        split_trim( config, ',', { remove_empty=true } )
    ASSERT_EQ( #items, 1 )
    ASSERT_EQ( items[1], 'xxx' )
  end
end

function Test.injections()
  ASSERT_EQ( string.split, nil )
  ASSERT_EQ( string.trim, nil )
  str.enable_string_injections()
  ASSERT_NEQ( string.split, nil )
  ASSERT_NEQ( string.trim, nil )
end
