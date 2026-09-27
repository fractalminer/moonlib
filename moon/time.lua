-----------------------------------------------------------------
-- Time-related functions.
-----------------------------------------------------------------
-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local posix_time = require'posix.time'

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local nanosleep = assert( posix_time.nanosleep )
local clock_gettime = assert( posix_time.clock_gettime )
local modf = assert( math.modf )
local floor = assert( math.floor )
local pack = assert( table.pack )
local unpack = assert( table.unpack )
local format = assert( string.format )
local insert = assert( table.insert )
local concat = assert( table.concat )

local CLOCK_REALTIME = posix_time.CLOCK_REALTIME

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
-- Argument is a floating point number giving number of seconds
-- to sleep.
local function sleep( secs )
  assert( secs and secs >= 0 )
  local integral, fractional = modf( secs )
  nanosleep{
    tv_sec=integral,
    tv_nsec=floor( fractional * 1000000000 ),
  }
end

-- Return the current epoch time in micros.
local function now_nanos()
  local spec = clock_gettime( CLOCK_REALTIME )
  local secs, nanos = spec.tv_sec, spec.tv_nsec
  return secs * 1000000000 + nanos
end

-- NOTE: We do integer division to get the us/ms/sec versionn
-- below (there may be things that depend on that).

local function now_micros() return now_nanos() // 1000 end

local function now_millis() return now_micros() // 1000 end

local function now_seconds() return now_millis() // 1000 end

-- Return runtime of function in micros, followed by any return
-- values of the function.
local function timeit_micros( func, ... )
  local start = now_micros()
  local res = pack( func( ... ) )
  local end_ = now_micros()
  return end_ - start, unpack( res )
end

local function format_human( nanos )
  assert( nanos % 1 == 0, 'integral nanos required' )
  nanos = floor( nanos )

  local ns = nanos
  local us = ns // 1000
  local ms = us // 1000
  local s = ms // 1000
  local m = s // 60

  local res = {}
  local function emit( fmt, ... )
    assert( type( fmt ) == 'string' )
    local nargs = select( '#', ... )
    if nargs == 0 then
      insert( res, fmt )
    else
      insert( res, format( fmt, ... ) )
    end
  end

  local function rtrim_zeroes( str )
    while str:sub( #str ) == '0' do
      str = str:sub( 1, #str - 1 )
    end
    if #str == 0 then str = '0' end
    return str
  end

  local function ltrim_zeroes( str )
    while str:sub( 1, 1 ) == '0' do str = str:sub( 2 ) end
    if #str == 0 then str = '0' end
    return str
  end

  local function emit_sub( sub )
    sub = sub % 1000
    if sub == 0 then return end
    emit( '.%s', rtrim_zeroes( format( '%03d', sub ) ) )
  end

  local function emit_sub_secs( sub )
    sub = sub % 60
    if sub == 0 then return end
    emit( '%ss', ltrim_zeroes( format( '%02d', sub ) ) )
  end

  local SMALL = 10

  local function tier( primary, secondary, unit )
    emit( '%s', primary )
    if primary < SMALL then emit_sub( secondary ) end
    emit( unit )
  end

  if m > 0 then
    emit( '%sm', m )
    if m < SMALL then emit_sub_secs( s ) end
  elseif s > 0 then
    tier( s, ms, 's' )
  elseif ms > 0 then
    tier( ms, us, 'ms' )
  elseif us > 0 then
    tier( us, ns, 'us' )
  else
    emit( '%sns', ns )
  end
  return concat( res )
end

-- out is a function that takes a string.
-- name will be used to label the output.
local function tcall( out, name, func, ... )
  assert( out )
  assert( name )
  assert( func )
  local start = now_nanos()
  local res = pack( func( ... ) )
  local finish = now_nanos()
  local delta_ns = finish - start
  local human = format_human( delta_ns )
  out( format( 'time[%s]: %s', name, human ) )
  return unpack( res )
end

local function timeit( name, fn )
  local function default_fn( delta_us )
    print( format( 'time[%s]: %dus', name, delta_us ) )
  end
  fn = fn or default_fn
  local mt = {
    now=now_micros(),
    __close=function( self ) fn( now_micros() - self.now ) end,
  }
  return setmetatable( { now=now_micros() }, mt )
end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return {
  sleep=sleep,
  now_nanos=now_nanos,
  now_micros=now_micros,
  now_millis=now_millis,
  now_seconds=now_seconds,
  timeit_micros=timeit_micros,
  timeit=timeit,
  format_human=format_human,
  tcall=tcall,
}
