-----------------------------------------------------------------
-- Tests for the printer module.
-----------------------------------------------------------------
local Test = ...

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local assertion = require'moon.unit.assertion'
local time = require'moon.time'

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
local ASSERT_GE = assertion.ASSERT_GE
local ASSERT_EQ = assertion.ASSERT_EQ
local ASSERT = assertion.ASSERT
local ASSERT_MATCH = assertion.ASSERT_MATCH

local format_human = assert( time.format_human )
local now_nanos = assert( time.now_nanos )
local now_micros = assert( time.now_micros )
local now_millis = assert( time.now_millis )
local now_seconds = assert( time.now_seconds )
local sleep = assert( time.sleep )
local tcall = assert( time.tcall )
local timeit_micros = assert( time.timeit_micros )
local timeit = assert( time.timeit )

-----------------------------------------------------------------
-- Test cases.
-----------------------------------------------------------------
function Test.now_nanos()
  local now = now_nanos()
  ASSERT_GE( now, 1706387206188896000 )
end

function Test.now_micros()
  local now = now_micros()
  ASSERT_GE( now, 1706387206188896 )
end

function Test.now_millis()
  local now = now_millis()
  ASSERT_GE( now, 1706387206188 )
end

function Test.now_seconds()
  local now = now_seconds()
  ASSERT_GE( now, 1706387206 )
end

-- This also tests sleep.
function Test.timeit_micros()
  local runtime, x, y, z = timeit_micros( function( n )
    sleep( .001 )
    return 3, n, 1
  end, 2 )
  ASSERT_GE( runtime, 900 )
  ASSERT_EQ( x, 3 )
  ASSERT_EQ( y, 2 )
  ASSERT_EQ( z, 1 )
end

function Test.timeit()
  local function handler( delta ) ASSERT( delta >= 10 ) end
  do
    local _<close> = timeit( 'hello', handler )
    sleep( .00001 ) -- 10us
  end
end

function Test.format_human()
  ASSERT_EQ( format_human( 0 ), '0ns' )
  ASSERT_EQ( format_human( 1 ), '1ns' )
  ASSERT_EQ( format_human( 10 ), '10ns' )
  ASSERT_EQ( format_human( 50 ), '50ns' )
  ASSERT_EQ( format_human( 100 ), '100ns' )
  ASSERT_EQ( format_human( 1000 ), '1us' )
  ASSERT_EQ( format_human( 1010 ), '1.01us' )
  ASSERT_EQ( format_human( 1100 ), '1.1us' )
  ASSERT_EQ( format_human( 1120 ), '1.12us' )
  ASSERT_EQ( format_human( 1123 ), '1.123us' )

  ASSERT_EQ( format_human( 1000 ), '1us' )
  ASSERT_EQ( format_human( 10000 ), '10us' )
  ASSERT_EQ( format_human( 50000 ), '50us' )
  ASSERT_EQ( format_human( 100000 ), '100us' )
  ASSERT_EQ( format_human( 1000000 ), '1ms' )
  ASSERT_EQ( format_human( 1100000 ), '1.1ms' )
  ASSERT_EQ( format_human( 1120000 ), '1.12ms' )
  ASSERT_EQ( format_human( 1123000 ), '1.123ms' )

  ASSERT_EQ( format_human( 1010 ), '1.01us' )
  ASSERT_EQ( format_human( 10020 ), '10us' )
  ASSERT_EQ( format_human( 50300 ), '50us' )
  ASSERT_EQ( format_human( 100040 ), '100us' )
  ASSERT_EQ( format_human( 1000005 ), '1ms' )
  ASSERT_EQ( format_human( 1100600 ), '1.1ms' )
  ASSERT_EQ( format_human( 1127000 ), '1.127ms' )
  ASSERT_EQ( format_human( 1123080 ), '1.123ms' )

  ASSERT_EQ( format_human( 1010000 ), '1.01ms' )
  ASSERT_EQ( format_human( 10020000 ), '10ms' )
  ASSERT_EQ( format_human( 50300000 ), '50ms' )
  ASSERT_EQ( format_human( 100040000 ), '100ms' )
  ASSERT_EQ( format_human( 1000005000 ), '1s' )
  ASSERT_EQ( format_human( 1100600000 ), '1.1s' )
  ASSERT_EQ( format_human( 1127000000 ), '1.127s' )
  ASSERT_EQ( format_human( 1123080000 ), '1.123s' )

  ASSERT_EQ( format_human( 1910000 ), '1.91ms' )
  ASSERT_EQ( format_human( 10320200 ), '10ms' )
  ASSERT_EQ( format_human( 51302300 ), '51ms' )
  ASSERT_EQ( format_human( 150040000 ), '150ms' )
  ASSERT_EQ( format_human( 1040005000 ), '1.04s' )
  ASSERT_EQ( format_human( 8100600000 ), '8.1s' )
  ASSERT_EQ( format_human( 9127000000 ), '9.127s' )
  ASSERT_EQ( format_human( 1123080000 ), '1.123s' )

  local _min = 60000000000
  local _sec = 1000000000

  ASSERT_EQ( format_human( _min ), '1m' )
  ASSERT_EQ( format_human( 2 * _min ), '2m' )
  ASSERT_EQ( format_human( 5 * _min ), '5m' )
  ASSERT_EQ( format_human( 10 * _min ), '10m' )
  ASSERT_EQ( format_human( _min + 5 * _sec ), '1m5s' )
  ASSERT_EQ( format_human( 2 * _min + 5 * _sec ), '2m5s' )
  ASSERT_EQ( format_human( 5 * _min + 5 * _sec ), '5m5s' )
  ASSERT_EQ( format_human( 5 * _min + 45 * _sec ), '5m45s' )
  ASSERT_EQ( format_human( 5 * _min + 50 * _sec ), '5m50s' )
  ASSERT_EQ( format_human( 10 * _min + 5 * _sec ), '10m' )

  ASSERT_EQ( format_human( 9100 ), '9.1us' )
  ASSERT_EQ( format_human( 10100 ), '10us' )
  ASSERT_EQ( format_human( 9100000 ), '9.1ms' )
  ASSERT_EQ( format_human( 10100000 ), '10ms' )
  ASSERT_EQ( format_human( 9100000000 ), '9.1s' )
  ASSERT_EQ( format_human( 10100000000 ), '10s' )
  ASSERT_EQ( format_human( 9.0 * _min ), '9m' )
  ASSERT_EQ( format_human( 10.0 * _min ), '10m' )
  ASSERT_EQ( format_human( 9.1 * _min ), '9m6s' )
  ASSERT_EQ( format_human( 10.1 * _min ), '10m' )
end

function Test.tcall()
  local function f( nanos ) sleep( nanos / 1000000000 ) end

  local res = ''
  local function out( what ) res = what end

  tcall( out, 'test', f, 2000 )
  -- Hopefully this won't be flaky... I suppose it could be if
  -- the machine is super slow, but seems to be ok.
  ASSERT_MATCH( res, '^time%[test%]: [0-9]+us$' )
end
