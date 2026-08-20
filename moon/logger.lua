-----------------------------------------------------------------
-- Logging.
-----------------------------------------------------------------
local M = {}

-----------------------------------------------------------------
-- Imports.
-----------------------------------------------------------------
local printer = require( 'moon.printer' )
local colors = require( 'moon.colors' )

local posix = require( 'posix' )

-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local format = string.format

local printfln = printer.printfln

local gettimeofday = assert( posix.gettimeofday )

local ANSI_NORMAL = colors.ANSI_NORMAL
local ANSI_GREEN = colors.ANSI_GREEN
local ANSI_RED = colors.ANSI_RED
local ANSI_INTENSE_YELLOW = colors.ANSI_INTENSE_YELLOW
local ANSI_BLUE = colors.ANSI_BLUE
local ANSI_MAGENTA = colors.ANSI_MAGENTA
local ANSI_BOLD = colors.ANSI_BOLD

-----------------------------------------------------------------
-- Levels
-----------------------------------------------------------------
M.levels = {
  OFF=0, --
  ERROR=1, --
  WARNING=2, --
  INFO=3, --
  DEBUG=4, --
  TRACE=5, --
}

M.level = M.levels.INFO

-----------------------------------------------------------------
-- Implementation.
-----------------------------------------------------------------
local function stamp()
  local ms = gettimeofday().usec // 1000
  return format( '%s.%03d', os.date( '%Y-%m-%d.%H:%M:%S' ), ms )
end

function M.info( fmt, ... )
  if M.level < M.levels.INFO then return end
  assert( fmt )
  local msg = format( fmt, ... )
  printfln( '%s %sINF%s %s', stamp(), ANSI_GREEN, ANSI_NORMAL,
            msg )
  io.flush()
end

function M.debug( fmt, ... )
  if M.level < M.levels.DEBUG then return end
  assert( fmt )
  local msg = format( fmt, ... )
  printfln( '%s %sDBG%s %s', stamp(), ANSI_BLUE, ANSI_NORMAL, msg )
  io.flush()
end

-- Deprecated: use `debug'
M.dbg = assert( M.debug )

function M.trace( fmt, ... )
  if M.level < M.levels.TRACE then return end
  assert( fmt )
  local msg = format( fmt, ... )
  printfln( '%s %sTRC%s %s', stamp(), ANSI_MAGENTA, ANSI_NORMAL,
            msg )
  io.flush()
end

function M.warn( fmt, ... )
  if M.level < M.levels.WARNING then return end
  assert( fmt )
  local msg = format( fmt, ... )
  printfln( '%s %sWRN%s %s', stamp(), ANSI_INTENSE_YELLOW,
            ANSI_NORMAL, msg )
  io.flush()
end

function M.err( fmt, ... )
  if M.level < M.levels.ERROR then return end
  assert( fmt )
  local msg = format( fmt, ... )
  printfln( '%s %s%sERR%s %s', stamp(), ANSI_RED, ANSI_BOLD,
            ANSI_NORMAL, msg )
  io.flush()
end

function M.fatal( fmt, ... )
  M.err( fmt, ... )
  os.exit( 1 )
end

function M.check( condition, ... )
  if not condition then M.fatal( ... ) end
end

function M.not_implemented() assert( false, 'not implemented' ) end

-----------------------------------------------------------------
-- Finished.
-----------------------------------------------------------------
return M
