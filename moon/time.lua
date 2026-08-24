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
local nanosleep = posix_time.nanosleep
local clock_gettime = posix_time.clock_gettime
local modf = math.modf
local floor = math.floor
local pack = table.pack
local unpack = table.unpack
local format = string.format

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
local function now_micros()
  local spec = clock_gettime( CLOCK_REALTIME )
  local secs, nanos = spec.tv_sec, spec.tv_nsec
  return secs * 1000000 + (nanos // 1000)
end

local function now_millis() return now_micros() / 1000 end

local function now_seconds() return now_micros() / 1000000 end

-- Return runtime of function in micros, followed by any return
-- values of the function.
local function timeit_micros( func )
  local start = now_micros()
  local res = pack( func() )
  local end_ = now_micros()
  return end_ - start, unpack( res )
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
  now_micros=now_micros,
  now_millis=now_millis,
  now_seconds=now_seconds,
  timeit_micros=timeit_micros,
  timeit=timeit,
}
